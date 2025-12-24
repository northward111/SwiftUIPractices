//
//  SyncUpDetail.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/24.
//

import Combine
import ComposableArchitecture
import SwiftUI

@Reducer
struct SyncUpDetail {
    @Reducer
    enum Destination {
        case alert(AlertState<Alert>)
        case editSyncUp(SyncUpForm)
        @CasePathable
        enum Alert {
            case confirmButtonTapped
        }
    }
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var syncUp: SyncUp
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
        case onAppear
        case syncUpUpdated(SyncUp)
        
        enum Delegate {
            case gotoMeeting(Meeting, syncUp: SyncUp)
            case gotoStartMeeting(Shared<SyncUp>)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.appDatabase) var appDatabase
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .syncUpUpdated(let syncUp):
                appDatabase.saveSyncUp(syncUp)
                return .none
            case .onAppear:
                return .publisher {
                    state.$syncUp.publisher.map(Action.syncUpUpdated)
                }
            case .startMeetingButtonTapped:
                return .send(.delegate(.gotoStartMeeting(state.$syncUp)))
            case .meetingTapped(let meeting):
                return .send(.delegate(.gotoMeeting(meeting, syncUp: state.syncUp)))
            case .delegate:
                return .none
            case .destination(.presented(.alert(.confirmButtonTapped))):
                @Shared(.syncUps) var syncUps: IdentifiedArrayOf<SyncUp> = []
                $syncUps.withLock {
                    _ = $0.remove(id: state.syncUp.id)
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
                state.destination = .editSyncUp(SyncUpForm.State(syncUp: state.syncUp))
                return .none
            case .cancelEditButtonTapped:
                state.destination = nil
                return .none
            case .doneEditButtonTapped:
                guard let editedSyncUp = state.destination?.editSyncUp?.syncUp else { return .none }
                state.$syncUp.withLock {
                    $0 = editedSyncUp
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
            ButtonState(role: .destructive, action: .confirmButtonTapped) {
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
                Button {
                    store.send(.startMeetingButtonTapped)
                } label: {
                    Label("Start Meeting", systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.accentColor)
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


            if !store.syncUp.meetings.isEmpty {
                Section {
                    ForEach(store.syncUp.meetings) { meeting in
                        Button {
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
                ForEach(store.syncUp.attendees) { attendee in
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
        .navigationTitle(Text(store.syncUp.title))
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
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
  NavigationStack {
    SyncUpDetailView(
      store: Store(
        initialState: SyncUpDetail.State(
          syncUp: Shared(value: .mock)
        )
      ) {
        SyncUpDetail()
      }
    )
  }
}




