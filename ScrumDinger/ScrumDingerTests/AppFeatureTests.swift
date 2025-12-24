//
//  AppFeatureTests.swift
//  ScrumDingerTests
//
//  Created by hn on 2025/11/25.
//

import ComposableArchitecture
import Testing

@testable import ScrumDinger

@MainActor
struct AppFeatureTests {

    @Test func delete() async throws {
        let syncUp = SyncUp.mock
        @Dependency(\.appDatabase) var appDatabase
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        appDatabase.saveSyncUp(syncUp)
        
        let sharedSyncUp = Shared(value: syncUp)
        await store.send(\.path.push, (id: 0, state: .detail(SyncUpDetail.State(syncUp: sharedSyncUp)))) {
            $0.path[id: 0] = .detail(SyncUpDetail.State(syncUp: sharedSyncUp))
        }
        
        await store.send(\.path[id: 0].detail.deleteButtonTapped) {
            $0.path[id: 0, case: \.detail]?.destination = .alert(.deleteConfirmation())
        }
        
        await store.send(\.path[id: 0].detail.destination.alert.confirmButtonTapped) {
            $0.path[id: 0, case: \.detail]?.destination = nil
            $0.syncUpsList.$syncUps.withLock {
                $0 = []
            }
        }
        
        await store.receive(\.path.popFrom) {
            $0.path = StackState()
        }
    }

}
