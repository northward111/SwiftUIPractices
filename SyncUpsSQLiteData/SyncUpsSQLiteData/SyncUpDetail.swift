//
//  SyncUpDetail.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/24.
//

import Combine
import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct SyncUpDetail {
    @Reducer
    enum Destination {
        case alert(AlertState<Alert>)
        case editSyncUp(SyncUpForm)
        @CasePathable
        enum Alert {
            case confirmDeletionButtonTapped
        }
    }
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        @FetchOne
        var syncUp: SyncUp
        @FetchAll
        var attendees: [Attendee]
        @FetchAll(Meeting.order { $0.date.desc() })
        var meetings: [Meeting]
        
        init(syncUp: SyncUp) {
            self._syncUp = FetchOne(wrappedValue: syncUp, SyncUp.find(syncUp.id))
            self._attendees = FetchAll(Attendee.where { $0.syncUpID.eq(syncUp.id) })
            self._meetings = FetchAll(Meeting.where { $0.syncUpID.eq(syncUp.id) }.order { $0.date.desc() })
        }
    }
    
    enum Action {
        case deleteButtonTapped
        case editButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case cancelEditButtonTapped
        case doneEditButtonTapped
        case delegate(Delegate)
        case meetingTapped(Meeting)
        case startMeetingButtonTapped

        enum Delegate {
            case gotoMeeting(Meeting, attendees: [Attendee])
            case gotoStartMeeting(SyncUp, attendees: [Attendee])
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.defaultDatabase) var database
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startMeetingButtonTapped:
                return .send(.delegate(.gotoStartMeeting(state.syncUp, attendees: state.attendees)))
            case .meetingTapped(let meeting):
                return .send(.delegate(.gotoMeeting(meeting, attendees: state.attendees)))
            case .delegate:
                return .none
            case .destination(.presented(.alert(.confirmDeletionButtonTapped))):
                withErrorReporting {
                    try database.write { db in
                        try SyncUp.delete(state.syncUp).execute(db)
                    }
                }
                return .run { _ in
                    await dismiss()
                }
            case .destination:
                return .none
            case .deleteButtonTapped:
                state.destination = .alert(.deleteConfirmation())
                return .none
            case .editButtonTapped:
                state.destination = .editSyncUp(SyncUpForm.State(syncUp: SyncUp.Draft(state.syncUp)))
                return .none
            case .cancelEditButtonTapped:
                state.destination = nil
                return .none
            case .doneEditButtonTapped:
                guard let editedSyncUp = state.destination?.editSyncUp?.syncUp, let editedAttendees = state.destination?.editSyncUp?.attendees else { return .none }
                withErrorReporting {
                    try database.write { db in
                        let syncUpID = try SyncUp.upsert { editedSyncUp }
                            .returning(\.id)
                            .fetchOne(db)!
                        try Attendee.delete()
                            .where { $0.syncUpID.eq(syncUpID) }
                            .execute(db)
                        try Attendee.upsert {
                            editedAttendees.map {
                                Attendee.Draft(id: $0.id, syncUpID: syncUpID, name: $0.name)
                            }
                        }.execute(db)
                    }
                }
                
                state.destination = nil
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension SyncUpDetail.Destination.State: Equatable {}

extension AlertState where Action == SyncUpDetail.Destination.Alert {
    static func deleteConfirmation() -> Self {
        AlertState {
            TextState("Delete?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDeletionButtonTapped) {
                TextState("Yes")
            }
            ButtonState(role: .cancel) {
                TextState("Nevermind")
            }
        } message: {
            TextState("Are you sure you want to delete this sync-up?")
        }
    }
}

struct SyncUpDetailView: View {
    @Bindable var store: StoreOf<SyncUpDetail>
    var body: some View {
        Form {
            Section {
                if store.attendees.isEmpty == false {
                    Button {
                        store.send(.startMeetingButtonTapped)
                    } label: {
                        Label("Start Meeting", systemImage: "timer")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                }
                HStack {
                    Label("Length", systemImage: "clock")
                    Spacer()
                    Text(store.syncUp.duration.formatted(.units()))
                }


                HStack {
                    Label("Theme", systemImage: "paintpalette")
                    Spacer()
                    Text(store.syncUp.theme.name)
                        .padding(4)
                        .foregroundColor(store.syncUp.theme.accentColor)
                        .background(store.syncUp.theme.mainColor)
                        .cornerRadius(4)
                }
            } header: {
                Text("Sync-up Info")
            }


            if !store.meetings.isEmpty {
                Section {
                    ForEach(store.meetings) { meeting in
                        Button {
                            store.send(.meetingTapped(meeting))
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(meeting.date, style: .date)
                                Text(meeting.date, style: .time)
                            }
                        }
                    }
                } header: {
                    Text("Past meetings")
                }
            }


            Section {
                ForEach(store.attendees) { attendee in
                    Label(attendee.name, systemImage: "person")
                }
            } header: {
                Text("Attendees")
            }


            Section {
                Button("Delete") {
                    store.send(.deleteButtonTapped)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(store.syncUp.title)
        .toolbar {
            Button("Edit") {
                store.send(.editButtonTapped)
            }
        }
        .sheet(item: $store.scope(state: \.destination?.editSyncUp, action: \.destination.editSyncUp)) { editSyncUpStore in
            NavigationStack {
                SyncUpFormView(store: editSyncUpStore)
                    .navigationTitle(store.syncUp.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                store.send(.cancelEditButtonTapped)
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                store.send(.doneEditButtonTapped)
                            }
                        }
                    }
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

#Preview {
  NavigationStack {
    SyncUpDetailView(
      store: Store(
        initialState: SyncUpDetail.State(
            syncUp: .mock
        )
      ) {
        SyncUpDetail()
      }
    )
  }
}




