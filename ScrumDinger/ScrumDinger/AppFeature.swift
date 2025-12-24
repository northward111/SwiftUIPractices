//
//  App.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @Reducer
    enum Path {
        case detail(SyncUpDetail)
        case meeting(Meeting, syncUp: SyncUp)
        case record(RecordMeeting)
    }
    @ObservableState
    struct State: Equatable {
        var syncUpsList = SyncUpsList.State()
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case syncUpsList(SyncUpsList.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.syncUpsList, action: \.syncUpsList) {
            SyncUpsList()
        }
        Reduce {
            state,
            action in
            switch action {
            case let .path(
                .element(
                    id: _,
                    action: .detail(
                        .delegate(.gotoMeeting(meeting, syncUp: syncUp))
                    )
                )
            ):
                state.path.append(.meeting(meeting, syncUp: syncUp))
                return .none
            case .path(
                .element(
                    id: _,
                    action: 
                            .detail(
                                .delegate(.gotoStartMeeting(let sharedSyncUp))
                            )
                )
            ):
                state.path
                    .append(.record(RecordMeeting.State(syncUp: sharedSyncUp)))
                return .none
            case .syncUpsList(.delegate(.gotoSyncUpDetail(let syncUpId))):
                guard let sharedSyncUp = Shared(state.syncUpsList.$syncUps[id: syncUpId]) else {
                    return .none
                }
                state.path
                    .append(.detail(SyncUpDetail.State(syncUp: sharedSyncUp)))
                return .none
            case .syncUpsList:
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension AppFeature.Path.State: Equatable {}

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            SyncUpsListView(
                store: store.scope(state: \.syncUpsList, action: \.syncUpsList)
            )
        } destination: { store in
            switch store.case {
            case .detail(let detailStore):
                SyncUpDetailView(store: detailStore)
            case let .meeting(meeting, syncUp: syncUp):
                MeetingView(meeting: meeting, syncUp: syncUp)
            case .record(let recordStore):
                RecordMeetingView(store: recordStore)
            }
        }
    }
}

#Preview {
    
    @Shared(.syncUps) var syncUps = {
        let syncUpId = SyncUp.ID()
        return [
            SyncUp(
                id: syncUpId,
                attendees: [
                    Attendee(
                        id: Attendee.ID(),
                        syncUpId: syncUpId,
                        name: "Blob"
                    ),
                    Attendee(
                        id: Attendee.ID(),
                        syncUpId: syncUpId,
                        name: "Blob Jr"
                    ),
                    Attendee(
                        id: Attendee.ID(),
                        syncUpId: syncUpId,
                        name: "Blob Sr"
                    ),
                ],
                duration: .seconds(6),
                meetings: [],
                theme: .orange,
                title: "Morning Sync"
            )
        ]
    }()
    AppView(
        store: Store(
            initialState: AppFeature.State(
                syncUpsList: SyncUpsList.State()
            )
        ) {
            AppFeature()
        }
    )
}


