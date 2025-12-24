//
//  MissionView.swift
//  Moonshot
//
//  Created by hn on 2025/10/15.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MissionDetailFeature {
    struct CrewMember: Equatable {
        let role: String
        let astronaut: Astronaut
    }
    @ObservableState
    struct State: Equatable {
        let mission: Mission
        let crew: [CrewMember]
        init(mission: Mission, astronauts: [String: Astronaut]) {
            self.mission = mission
            self.crew = mission.crew.map({ crewRole in
                if let astronaut = astronauts[crewRole.name] {
                    return CrewMember(role: crewRole.role, astronaut: astronaut)
                }else {
                    fatalError("Missing \(crewRole.name)")
                }
            })
        }
    }
    
    enum Action {
        case crewMemberTapped(CrewMember)
        case delegate(Delegate)
        
        enum Delegate {
            case showAstronaut(Astronaut)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .crewMemberTapped(let crewMember):
                return .send(.delegate(.showAstronaut(crewMember.astronaut)))
            case .delegate:
                return .none
            }
        }
    }
}

struct MissionDetailView: View {
    let store: StoreOf<MissionDetailFeature>
    struct CrewView: View {
        let crew: [MissionDetailFeature.CrewMember]
        let store: StoreOf<MissionDetailFeature>
        var body: some View {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(crew, id: \.role) { crewMember in
                        Button {
                            store.send(.crewMemberTapped(crewMember))
                        } label: {
                            HStack {
                                Image(crewMember.astronaut.id)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 104, height: 72)
                                    .clipShape(.capsule)
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(.white, lineWidth:1)
                                    }
                                VStack(alignment: .leading) {
                                    Text(crewMember.astronaut.name)
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                    Text(crewMember.role)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
    struct DividerView: View {
        var body: some View {
            Rectangle()
                .frame(height: 2)
                .foregroundStyle(.lightBackground)
                .padding(.vertical)
        }
    }
    var body: some View {
        ScrollView {
            VStack {
                Image(store.mission.image)
                    .resizable()
                    .scaledToFit()
                    .containerRelativeFrame(.horizontal) { width, _ in
                        width * 0.6
                    }
                    .padding(.top)
                    .accessibilityHidden(true)
                Text(store.mission.formattedLaunchDate)
                    .font(.title)
                    .accessibilityLabel(store.mission.formattedLaunchDateLabel)
                DividerView()
                VStack(alignment: .leading) {
                    Text("Mission Highlights")
                        .font(.title.bold())
                        .padding(.bottom, 5)
                    
                    Text(store.mission.description)
                    DividerView()
                    Text("Crew")
                        .font(.title.bold())
                        .padding(.bottom, 5)
                }
                .padding(.horizontal)
                CrewView(crew: store.crew, store: store)
            }
            .padding(.bottom)
        }
        .navigationTitle(store.mission.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(.darkBackground)
    }
}



#Preview {
    let dummyMission = (Bundle.main.decode("missions.json") as [Mission])[0]
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")
    let store = Store(initialState: MissionDetailFeature.State(mission: dummyMission, astronauts: astronauts)) {
        MissionDetailFeature()
    }
    return MissionDetailView(store: store)
        .preferredColorScheme(.dark)
}
