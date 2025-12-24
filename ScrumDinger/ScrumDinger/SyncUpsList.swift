//
//  SyncUpsList.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/24.
//

import ComposableArchitecture
import GRDB
import SwiftUI

@Reducer
struct SyncUpsList {
    @ObservableState
    struct State: Equatable {
        @Presents var addSyncUp: SyncUpForm.State?
        @Shared var syncUps: IdentifiedArrayOf<SyncUp>
        
        init(syncUps: [SyncUp] = []) {
            self.addSyncUp = nil
            self._syncUps = Shared(value: IdentifiedArray(uniqueElements: syncUps))
        }
    }
    
    enum Action {
        case addSyncUpButtonTapped
        case syncUpTapped(SyncUp.ID)
        case onDelete(IndexSet)
        case addSyncUp(PresentationAction<SyncUpForm.Action>)
        case discardButtonTapped
        case confirmAddButtonTapped
        case delegate(Delegate)
        case onAppear
        case syncUpsLoaded([SyncUp])
        
        enum Delegate {
            case gotoSyncUpDetail(SyncUp.ID)
        }
    }
    
    @Dependency(\.uuid) var uuid
    @Dependency(\.appDatabase) var appDatabase
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .syncUpsLoaded(let syncUps):
                state.$syncUps.withLock {
                    $0 = IdentifiedArray(uniqueElements: syncUps)
                }
                return .none
            case .onAppear:
                return .run { send in
                    await send(.syncUpsLoaded(appDatabase.fetchAllSyncUps()))
                }
            case .delegate:
                return .none
            case .addSyncUpButtonTapped:
                state.addSyncUp = SyncUpForm.State(syncUp: SyncUp(id: uuid()))
                return .none
            case .addSyncUp:
                return .none
            case .syncUpTapped(let id):
                return .send(.delegate(.gotoSyncUpDetail(id)))
            case .onDelete(let indices):
                let ids = indices.map { state.syncUps[$0].id }
                state.$syncUps.withLock {
                    $0.remove(atOffsets: indices)
                }
                appDatabase.deleteSyncUps(ids: ids)
                return .none
            case .confirmAddButtonTapped:
                guard let newSyncUp = state.addSyncUp?.syncUp else {
                    return .none
                }
                state.addSyncUp = nil
                state.$syncUps.withLock {
                    _ = $0.append(newSyncUp)
                }
                appDatabase.saveSyncUp(newSyncUp)
                return .none
            case .discardButtonTapped:
                state.addSyncUp = nil
                return .none
            }
        }
        .ifLet(\.$addSyncUp, action: \.addSyncUp) {
            SyncUpForm()
        }
    }
}

struct SyncUpsListView: View {
    @Bindable var store: StoreOf<SyncUpsList>
    var body: some View {
        List {
            ForEach(store.syncUps) { syncUp in
                Button {
                    store.send(.syncUpTapped(syncUp.id))
                } label: {
                    CardView(syncUp: syncUp)
                }
                .listRowBackground(syncUp.theme.mainColor)
            }
            .onDelete { indexSet in
                store.send(.onDelete(indexSet))
            }
        }
        .sheet(
            item: $store.scope(
                state: \.addSyncUp,
                action: \.addSyncUp
            ),
            content: { addSyncUpStore in
                NavigationStack {
                    SyncUpFormView(store: addSyncUpStore)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Discard") {
                                    store.send(.discardButtonTapped)
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add") {
                                    store.send(.confirmAddButtonTapped)
                                }
                            }
                        }
                }
            })
        .toolbar {
            Button {
                store.send(.addSyncUpButtonTapped)
            } label: {
                Image(systemName: "plus")
            }
        }
        .navigationTitle("Daily Sync-ups")
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct CardView: View {
    let syncUp: SyncUp


    var body: some View {
        VStack(alignment: .leading) {
            Text(syncUp.title)
                .font(.headline)
            Spacer()
            HStack {
                Label("\(syncUp.attendees.count)", systemImage: "person.3")
                Spacer()
                Label(syncUp.duration.formatted(.units()), systemImage: "clock")
                    .labelStyle(.trailingIcon)
            }
            .font(.caption)
        }
        .padding()
        .foregroundStyle(syncUp.theme.accentColor)
    }
}


struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: DefaultLabelStyle.Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}


extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: Self { Self() }
}

extension SharedKey where Self == FileStorageKey<IdentifiedArrayOf<SyncUp>>.Default {
    static var syncUps: Self {
        Self[
            .fileStorage(
                .documentsDirectory.appending(component: "sync-ups.json")
            ),
            default: []
        ]
    }
}

#Preview {
    @Shared(.syncUps) var syncUps = [.mock]
    NavigationStack {
        SyncUpsListView(
            store: Store(
                initialState: SyncUpsList.State()
            ) {
                SyncUpsList()
                    ._printChanges()
            }
        )
    }
}

