//
//  SyncUpForm.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/24.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct SyncUpForm {
    struct AttendeeDraft: Equatable, Identifiable {
        let id: UUID
        var name = ""
    }
    @ObservableState
    struct State: Equatable {
        var focus: Field? = .title
        var syncUp: SyncUp.Draft
        var attendees: [AttendeeDraft] = []
        
        enum Field: Hashable {
            case attendee(Attendee.ID)
            case title
        }
    }
    
    enum Action: BindableAction {
        case addAttendeeButtonTapped
        case binding(BindingAction<State>)
        case onDeleteAttendees(IndexSet)
        case onAppear
    }
    
    @Dependency(\.uuid) var uuid
    @Dependency(\.defaultDatabase) var database
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                guard let syncUpID = state.syncUp.id else { return .none }
                withErrorReporting {
                    state.attendees = try database.read { db in
                        try Attendee.all
                            .where { $0.syncUpID.eq(syncUpID) }
                            .fetchAll(db)
                            .map { AttendeeDraft(id: $0.id, name: $0.name) }
                    }
                }
                return .none
            case .addAttendeeButtonTapped:
                let attendee = AttendeeDraft(id: uuid())
                state.attendees.append(attendee)
                state.focus = .attendee(attendee.id)
                return .none
            case .binding:
                return .none
            case .onDeleteAttendees(let indices):
                state.attendees.remove(atOffsets: indices)
                guard
                    !state.attendees.isEmpty,
                    let firstIndex = indices.first
                else {
                    let attendee = AttendeeDraft(id: uuid())
                    state.attendees.append(attendee)
                    state.focus = .attendee(attendee.id)
                    return .none
                }
                let index = min(firstIndex, state.attendees.count - 1)
                state.focus = .attendee(state.attendees[index].id)
                return .none
            }
        }
    }
}

struct SyncUpFormView: View {
    @Bindable var store: StoreOf<SyncUpForm>
    @FocusState var focus: SyncUpForm.State.Field?

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $store.syncUp.title)
                    .focused($focus, equals: .title)
                HStack {
                    Slider(
                        value: $store.syncUp.duration.minutes,
                        in: 5...30,
                        step: 1
                    ) {
                        Text("Length")
                    }
                    Spacer()
                    Text(store.syncUp.duration.formatted(.units()))
                }
                ThemePicker(selection: $store.syncUp.theme)
            } header: {
                Text("Sync-up Info")
            }
            Section {
                ForEach($store.attendees) { $attendee in
                    TextField("Name", text: $attendee.name)
                        .focused($focus, equals: .attendee(attendee.id))
                }
                .onDelete { indices in
                    store.send(.onDeleteAttendees(indices))
                }

                Button("New attendee") {
                    store.send(.addAttendeeButtonTapped)
                }
            } header: {
                Text("Attendees")
            }
        }
        .bind($store.focus, to: $focus)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct ThemePicker: View {
    @Binding var selection: Theme

    var body: some View {
        Picker("Theme", selection: $selection) {
            ForEach(Theme.allCases) { theme in
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.mainColor)
                    Label(theme.name, systemImage: "paintpalette")
                        .padding(4)
                }
                .foregroundStyle(theme.accentColor)
                .fixedSize(horizontal: false, vertical: true)
                .tag(theme)
            }
        }
    }
}


extension Duration {
    fileprivate var minutes: Double {
        get { Double(components.seconds / 60) }
        set { self = .seconds(newValue * 60) }
    }
}

//#Preview {
//  SyncUpFormView(
//    store: Store(
//      initialState: SyncUpForm.State(
//        syncUp: .mock
//      )
//    ) {
//      SyncUpForm()
//    }
//  )
//}

