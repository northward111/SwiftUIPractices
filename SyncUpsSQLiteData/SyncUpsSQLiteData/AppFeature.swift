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
        case meeting(Meeting, attendees: [Attendee])
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
                        .delegate(.gotoMeeting(meeting, attendees: attendees))
                    )
                )
            ):
                state.path.append(.meeting(meeting, attendees: attendees))
                return .none
            case let .path(
                .element(
                    id: _,
                    action: 
                            .detail(
                                .delegate(.gotoStartMeeting(syncUp, attendees: attendees))
                            )
                )
            ):
                state.path
                    .append(.record(RecordMeeting.State(syncUp: syncUp, attendees: attendees)))
                return .none
            case .syncUpsList(.delegate(.gotoSyncUpDetail(let syncUp))):
                state.path
                    .append(.detail(SyncUpDetail.State(syncUp: syncUp)))
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
            case let .meeting(meeting, attendees: attendees):
                MeetingView(meeting: meeting, attendees: attendees)
            case .record(let recordStore):
                RecordMeetingView(store: recordStore)
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(
            initialState: AppFeature.State()
        ) {
            AppFeature()
        }
    )
}


