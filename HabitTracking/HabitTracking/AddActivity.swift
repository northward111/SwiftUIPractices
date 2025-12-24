//
//  AddActivity.swift
//  HabitTracking
//
//  Created by hn on 2025/10/21.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddActivityFeature {
    @ObservableState
    struct State: Equatable {
        var name = ""
        var description = ""
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case submitButtonTapped(Activity)
        case delegate(Delegate)
        enum Delegate {
            case addActivity(Activity)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .submitButtonTapped(let activity):
                return .concatenate(
                    .send(.delegate(.addActivity(activity))),
                    .run { send in
                        await self.dismiss()
                    }
                )
            case .delegate:
                return .none
            }
        }
    }
}

struct AddActivity: View {
    @Bindable var store: StoreOf<AddActivityFeature>
    var body: some View {
        Form {
            TextField("Name", text: $store.name)
            TextField("Description", text: $store.description)
        }
        .formStyle(.grouped)
        .navigationTitle("Add a new activity")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Submit") {
                store.send(.submitButtonTapped(Activity(name: store.name, description: store.description, count: 0)))
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddActivity(store: Store(initialState: AddActivityFeature.State(), reducer: {
            AddActivityFeature()
        }))
    }
}
