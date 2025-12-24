//
//  SyncUpsListTests.swift
//  ScrumDingerTests
//
//  Created by hn on 2025/11/24.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import ScrumDinger

@MainActor
struct SyncUpsListTests {
    @Test func deletion() async throws {
        let syncUp = SyncUp(
            id: SyncUp.ID(),
            title: "Point-Free Morning Sync"
        )
        let store = TestStore(initialState: SyncUpsList.State(syncUps: [syncUp])) {
            SyncUpsList()
                ._printChanges()
        }
        @Dependency(\.appDatabase) var appDatabase
        appDatabase.saveSyncUp(syncUp)
        
        await store.send(.onDelete([0])) {
            $0.$syncUps.withLock {
                $0 = []
            }
        }
        
    }
    
    @Test func addSyncUp() async throws {
        let syncUpId = SyncUp.ID(0)
        let store = TestStore(initialState: SyncUpsList.State()) {
            SyncUpsList()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        
        await store.send(.addSyncUpButtonTapped) {
            $0.addSyncUp = SyncUpForm.State(syncUp: SyncUp(id: syncUpId))
        }
        
        let editedSyncUp = SyncUp(
            id: SyncUp.ID(0),
            attendees: [
                Attendee(id: Attendee.ID(), syncUpId: syncUpId, name: "Blob"),
                Attendee(id: Attendee.ID(), syncUpId: syncUpId, name: "Blob Jr."),
            ],
            title: "Point-Free morning sync"
        )
        await store.send(\.addSyncUp.binding.syncUp, editedSyncUp) {
            $0.addSyncUp?.syncUp = editedSyncUp
        }
        
        await store.send(.confirmAddButtonTapped) {
            $0.addSyncUp = nil
            $0.$syncUps.withLock {
                $0 = [editedSyncUp]
            }
        }
    }
    
    @Test func addSyncUpNonExhaustive() async throws {
        let syncUpId = SyncUp.ID(0)
        let store = TestStore(initialState: SyncUpsList.State()) {
            SyncUpsList()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.addSyncUpButtonTapped)
        let editedSyncUp = SyncUp(
            id: syncUpId,
            attendees: [
                Attendee(id: Attendee.ID(), syncUpId: syncUpId, name: "Blob"),
                Attendee(id: Attendee.ID(), syncUpId: syncUpId, name: "Blob Jr."),
            ],
            title: "Point-Free morning sync"
        )
        await store.send(\.addSyncUp.binding.syncUp, editedSyncUp)
        
        await store.send(.confirmAddButtonTapped) {
            $0.$syncUps.withLock {
                $0 = [editedSyncUp]
            }
        }
    }
}
