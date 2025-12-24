//
//  SyncUpsList.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/24.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct SyncUpsList {
    @ObservableState
    struct State: Equatable {
        @Presents var addSyncUp: SyncUpForm.State?
        @FetchAll(
            SyncUp
                .group(by: \.id)
                .leftJoin(Attendee.all) { $0.id.eq($1.syncUpID) }
                .select { Row.Columns(attendeeCount: $1.count(), syncUp: $0) },
            animation: .default
        )
        var rawSyncUps: [Row]
        
        var syncUps: IdentifiedArrayOf<Row> {
            IdentifiedArray(uniqueElements: rawSyncUps)
        }
        
        @Selection
        struct Row: Equatable, Identifiable {
            let attendeeCount: Int
            let syncUp: SyncUp

            var id: SyncUp.ID { syncUp.id }
        }
    }
    
    enum Action {
        case addSyncUpButtonTapped
        case syncUpTapped(SyncUp)
        case onDelete(IndexSet)
        case addSyncUp(PresentationAction<SyncUpForm.Action>)
        case discardButtonTapped
        case confirmAddButtonTapped
        case delegate(Delegate)
#if DEBUG
        case seedDatabaseButtonTapped
#endif
        
        enum Delegate {
            case gotoSyncUpDetail(SyncUp)
        }
    }
    
    @Dependency(\.uuid) var uuid
    @Dependency(\.defaultDatabase) var database
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .addSyncUpButtonTapped:
                state.addSyncUp = SyncUpForm
                    .State(syncUp: SyncUp.Draft(id: uuid()))
                return .none
            case .addSyncUp:
                return .none
            case .syncUpTapped(let syncUp):
                return .send(.delegate(.gotoSyncUpDetail(syncUp)))
            case .onDelete(let indices):
                let syncUpIDs = indices.map { state.syncUps[$0].syncUp.id }
                withErrorReporting {
                    try database.write { db in
                        try SyncUp.delete().where {
                            $0.id.in(syncUpIDs)
                        }.execute(db)
                    }
                }
                return .none
            case .confirmAddButtonTapped:
                guard let newSyncUp = state.addSyncUp?.syncUp else {
                    return .none
                }
                state.addSyncUp = nil
                withErrorReporting {
                    try database.write { db in
                        try SyncUp.upsert {
                            newSyncUp
                        }.execute(db)
                    }
                }
                
                
                //                appDatabase.saveSyncUp(newSyncUp)
                return .none
            case .discardButtonTapped:
                state.addSyncUp = nil
                return .none
#if DEBUG
            case .seedDatabaseButtonTapped:
                seedDatabase()
                return .none
#endif
            }
        }
        .ifLet(\.$addSyncUp, action: \.addSyncUp) {
            SyncUpForm()
        }
    }
    
#if DEBUG
    func seedDatabase() {
        withErrorReporting {
            try database.write { db in
                try db.seedSampleData()
            }
        }
    }
#endif // DEBUG
}

struct SyncUpsListView: View {
    @Bindable var store: StoreOf<SyncUpsList>
    var body: some View {
        List {
            ForEach(store.syncUps) { row in
                Button {
                    store.send(.syncUpTapped(row.syncUp))
                } label: {
                    CardView(
                        syncUp: row.syncUp,
                        attendeeCount: row.attendeeCount
                    )
                }
                .listRowBackground(row.syncUp.theme.mainColor)
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
            ToolbarItem {
                Button {
                    store.send(.addSyncUpButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }
            
#if DEBUG
            ToolbarItem {
                Button("Seed") {
                    store.send(.seedDatabaseButtonTapped)
                }
            }
#endif
        }
        .navigationTitle("Daily Sync-ups")
    }
}

struct CardView: View {
    let syncUp: SyncUp
    let attendeeCount: Int


    var body: some View {
        VStack(alignment: .leading) {
            Text(syncUp.title)
                .font(.headline)
            Spacer()
            HStack {
                Label("\(attendeeCount)", systemImage: "person.3")
                Spacer()
                Label(
                    Duration.seconds(syncUp.seconds).formatted(.units()),
                    systemImage: "clock"
                )
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

#Preview {
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

