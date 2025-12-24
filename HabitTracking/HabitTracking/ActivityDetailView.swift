//
//  ActivityDetailView.swift
//  HabitTracking
//
//  Created by hn on 2025/10/22.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ActivityDetailFeature {
    @ObservableState
    struct State: Equatable {
        var activity: Activity
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate {
            case updateActivity(Activity)
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .send(.delegate(.updateActivity(state.activity)))
            case .delegate:
                return .none
            }
        }
    }
}


struct ActivityDetailView: View {
    @Bindable var store: StoreOf<ActivityDetailFeature>
    var body: some View {
        VStack {
            Text(store.activity.name)
                .font(.headline)
            Text(store.activity.description)
                .font(.subheadline)
            Stepper("Count \(store.activity.count)", value: $store.activity.count)
                .padding(.horizontal)
        }
    }
}

//#Preview {
//    @Previewable @State var activities = Activities()
//    let activity = Activity.sample()
//    NavigationStack {
//        ActivityDetailView(activities: $activities, activity: activity)
//    }
//}
