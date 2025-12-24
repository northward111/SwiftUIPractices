//
//  SyncUpDetailTests.swift
//  ScrumDingerTests
//
//  Created by hn on 2025/11/25.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import ScrumDinger

@MainActor
struct SyncUpDetailTests {

    @Test func edit() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let syncUp = SyncUp(
            id: SyncUp.ID(),
            title: "Point-Free Morning Sync"
        )
        let store = TestStore(
            initialState: SyncUpDetail.State(syncUp: Shared(value: syncUp))
        ) {
            SyncUpDetail()
        }
        
        await store.send(.editButtonTapped) {
            $0.destination = .editSyncUp(SyncUpForm.State(syncUp: syncUp))
        }
        
        var editedSyncUp = syncUp
        editedSyncUp.title = "Point-Free Evening Sync"
        await store.send(\.destination.editSyncUp.binding.syncUp, editedSyncUp) {
            $0.destination.modify(\.editSyncUp) {
                $0.syncUp = editedSyncUp
            }
        }
        
        await store.send(.doneEditButtonTapped) {
            $0.destination = nil
            $0.$syncUp.withLock {
                $0 = editedSyncUp
            }
        }
    }
    
    @Test func editNonExhaustive() async throws {
        let syncUp = SyncUp(
            id: SyncUp.ID(),
            title: "Point-Free Morning Sync"
        )
        let store = TestStore(
            initialState: SyncUpDetail.State(syncUp: Shared(value: syncUp))
        ) {
            SyncUpDetail()
        }
        store.exhaustivity = .off
        
        await store.send(.editButtonTapped)
        
        var editedSyncUp = syncUp
        editedSyncUp.title = "Point-Free Evening Sync"
        await store.send(\.destination.editSyncUp.binding.syncUp, editedSyncUp)
        
        await store.send(.doneEditButtonTapped) {
            $0.$syncUp.withLock {
                $0 = editedSyncUp
            }
        }
    }

}

