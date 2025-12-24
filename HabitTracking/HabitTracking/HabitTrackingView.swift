//
//  ContentView.swift
//  HabitTracking
//
//  Created by hn on 2025/10/21.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct HabitTrackingFeature {
    @ObservableState
    struct State: Equatable {
        var activities: IdentifiedArrayOf<Activity> = []
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case addButtonTapped
        case activityCellTapped(Activity)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .activityCellTapped(let activity):
                state.path.append(.activityDetail(.init(activity: activity)))
                return .none
            case .addButtonTapped:
                state.path.append(.addActivity(.init()))
                return .none
            case .path(.element(id: _, action: .addActivity(.delegate(.addActivity(let activity))))):
                state.activities.append(activity)
                return .none
            case .path(.element(id: _, action: .activityDetail(.delegate(.updateActivity(let activity))))):
                state.activities.updateOrAppend(activity)
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension HabitTrackingFeature {
    @Reducer
    enum Path {
        case addActivity(AddActivityFeature)
        case activityDetail(ActivityDetailFeature)
    }
}

extension HabitTrackingFeature.Path.State: Equatable {}

struct ActivityCell: View {
    let activity: Activity
    var body: some View {
        HStack {
            Text(activity.name)
                .font(.headline)
            Spacer()
            Text("\(activity.count)")
                .font(.body)
        }
    }
}

struct HabitTrackingView: View {
    @Bindable var store: StoreOf<HabitTrackingFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List(store.activities) { activity in
                Button {
                    store.send(.activityCellTapped(activity))
                } label: {
                    ActivityCell(activity: activity)
                }
            }
            .navigationTitle("HabitTracking")
            .toolbar {
                Button {
                    store.send(.addButtonTapped)
                } label: {
                    Text("Add")
                }
            }
        } destination: { store in
            switch store.case {
            case .activityDetail(let childStore):
                ActivityDetailView(store: childStore)
            case .addActivity(let childStore):
                AddActivity(store: childStore)
            }
        }
    }
}

#Preview {
    HabitTrackingView(store: Store(initialState: HabitTrackingFeature.State(), reducer: {
        HabitTrackingFeature()
    }))
}
