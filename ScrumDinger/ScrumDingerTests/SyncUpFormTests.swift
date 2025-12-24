//
//  SyncUpFormTests.swift
//  ScrumDingerTests
//
//  Created by hn on 2025/11/24.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import ScrumDinger

@MainActor
struct SyncUpFormTests {
    @Test func removeAttendee() async throws {
        let syncUpId = SyncUp.ID()
        let attendee1 = Attendee(id: Attendee.ID(), syncUpId: syncUpId)
        let attendee2 = Attendee(id: Attendee.ID(), syncUpId: syncUpId)
        let store = TestStore(initialState: SyncUpForm.State(syncUp: SyncUp(
            id: syncUpId,
            attendees: [
                attendee1,
                attendee2
            ]
        ))) {
            SyncUpForm()
                ._printChanges()
        }
        
        await store.send(.onDeleteAttendees([0])) {
            $0.syncUp.attendees.removeFirst()
            $0.focus = .attendee(attendee2.id)
        }
    }
    
    @Test func removeFocusedAttendee() async throws {
        let syncUpId = SyncUp.ID()
        let attendee1 = Attendee(id: Attendee.ID(), syncUpId: syncUpId)
        let attendee2 = Attendee(id: Attendee.ID(), syncUpId: syncUpId)
        let store = TestStore(initialState: SyncUpForm.State(focus: .attendee(attendee1.id), syncUp: SyncUp(
            id: syncUpId,
            attendees: [
                attendee1,
                attendee2
            ]
        ))) {
            SyncUpForm()
                ._printChanges()
        }
        
        await store.send(.onDeleteAttendees([0])) {
            $0.syncUp.attendees.removeFirst()
            $0.focus = .attendee(attendee2.id)
        }
    }
    
    @Test func addAttendee() async throws {
        let syncUpId = SyncUp.ID()
        let store = TestStore(initialState: SyncUpForm.State(syncUp: SyncUp(id: syncUpId))) {
            SyncUpForm()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        
        await store.send(.addAttendeeButtonTapped) {
            $0.focus = .attendee(Attendee.ID(0))
            $0.syncUp.attendees.append(Attendee(id: Attendee.ID(0), syncUpId: syncUpId))
        }
    }
    
    @Test func removeLastAttendee() async throws {
        let syncUpId = SyncUp.ID()
        let store = TestStore(
            initialState: SyncUpForm
                .State(
                    syncUp: SyncUp(
                        id: syncUpId,
                        attendees: [Attendee(id: Attendee.ID(), syncUpId: syncUpId)]
                    )
                )
        ) {
            SyncUpForm()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        
        await store.send(.onDeleteAttendees([0])) {
            $0.syncUp.attendees = [Attendee(id: Attendee.ID(0), syncUpId: syncUpId)]
            $0.focus = .attendee(Attendee.ID(0))
        }
    }
}

