//
//  MoonshotFeature.swift
//  Moonshot
//
//  Created by hn on 2025/11/17.
//

import ComposableArchitecture
import SwiftUI

struct MissionDataSource {
    var missionSource: () -> [Mission]
    var astronautSource: () -> [String: Astronaut]
}

private enum MissionDataSourceDependencyKey: DependencyKey {
    static var liveValue = MissionDataSource {
        Bundle.main.decode("missions.json")
    } astronautSource: {
        Bundle.main.decode("astronauts.json")
    }
}

extension DependencyValues {
    var missionDataSource: MissionDataSource {
        get {
            return self[MissionDataSourceDependencyKey.self]
        }
        set {
            self[MissionDataSourceDependencyKey.self] = newValue
        }
    }
}
@Reducer
struct MoonshotFeature {
    @ObservableState
    struct State: Equatable {
        var isList = false
        var missions: [Mission] = []
        var astronauts: [String: Astronaut] = [:]
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case onAppear
        case listGridToggleButtonTapped
        case path(StackActionOf<Path>)
        case missionCellClicked(Mission)
    }
    
    @Dependency(\.missionDataSource) var missionDataSource
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                loadMissionAndAstronauts(state: &state)
            case .listGridToggleButtonTapped:
                state.isList.toggle()
            case .path(.element(id: _, action: .missionDetail(.delegate(.showAstronaut(let astronaut))))):
                state.path.append(.astronaut(.init(astronaut: astronaut)))
            case .path:
                break
            case .missionCellClicked(let mission):
                state.path.append(.missionDetail(.init(mission: mission, astronauts: state.astronauts)))
            }
            return .none
        }
        .forEach(\.path, action: \.path)
    }
    
    func loadMissionAndAstronauts(state: inout State) {
        state.missions = missionDataSource.missionSource()
        state.astronauts = missionDataSource.astronautSource()
    }
}

extension MoonshotFeature {
    @Reducer
    enum Path {
        case missionDetail(MissionDetailFeature)
        case astronaut(AstronautFeature)
    }
}

extension MoonshotFeature.Path.State: Equatable {}

struct MissionCell: View {
    let mission: Mission
    var body: some View {
        VStack {
            Image(mission.image)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
            VStack {
                Text(mission.displayName)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(mission.formattedLaunchDate)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .accessibilityLabel(mission.formattedLaunchDateLabel)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(.lightBackground)
        }
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.lightBackground)
        }
    }
}

struct MoonshotView: View {
    @Bindable var store: StoreOf<MoonshotFeature>
    struct GridLayout: View {
        let missions: [Mission]
        let astronauts: [String: Astronaut]
        let store: StoreOf<MoonshotFeature>
        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(missions) { mission in
                        Button {
                            store.send(.missionCellClicked(mission))
                        } label: {
                            MissionCell(mission: mission)
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
    }
    struct ListLayout: View {
        let missions: [Mission]
        let astronauts: [String: Astronaut]
        let store: StoreOf<MoonshotFeature>
        var body: some View {
            List(missions) { mission in
                Button {
                    store.send(.missionCellClicked(mission))
                } label: {
                    MissionCell(mission: mission)
                }
                .listRowBackground(Color.darkBackground)
            }
            .listStyle(.plain)
        }
    }
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Group {
                if store.isList {
                    ListLayout(missions: store.missions, astronauts: store.astronauts, store: store)
                }else {
                    GridLayout(missions: store.missions, astronauts: store.astronauts, store: store)
                }
            }
            .navigationTitle("Moonshot")
            .background(.darkBackground)
            .preferredColorScheme(.dark)
            .toolbar {
                Button("Grid|List") {
                    store.send(.listGridToggleButtonTapped)
                }
                .accessibilityLabel("Grid or List")
            }
        } destination: { navigationStore in
            switch navigationStore.case {
            case .missionDetail(let store):
                MissionDetailView(store: store)
            case .astronaut(let store):
                AstronautView(store: store)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
