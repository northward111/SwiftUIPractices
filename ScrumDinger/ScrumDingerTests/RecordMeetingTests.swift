//
//  RecordMeetingTests.swift
//  ScrumDingerTests
//
//  Created by hn on 2025/11/26.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import ScrumDinger

@MainActor
struct RecordMeetingTests {

    @Test func timerfinishes() async throws {
        let clock = TestClock()
        let syncUpId = SyncUp.ID()
        let syncUp = SyncUp(
            id: syncUpId,
            attendees: [
                Attendee(id: Attendee.ID(), syncUpId: syncUpId, name: "Blob"),
                Attendee(id: Attendee.ID(), syncUpId: syncUpId ,name: "Blob Jr"),
            ],
            duration: .seconds(4),
            title: "Morning Sync"
        )
        let store = TestStore(initialState: RecordMeeting.State(syncUp: Shared(value: syncUp))) {
            RecordMeeting()
        } withDependencies: {
            $0.continuousClock = clock
            $0.uuid = .incrementing
            $0.date.now = Date(timeIntervalSince1970: 1234567890)
            $0.dismiss = DismissEffect {}
        }
        
        let onAppearTask = await store.send(.onAppear)
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.secondsElapsed = 1
        }
        
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.speakerIndex = 1
            $0.secondsElapsed = 2
        }
        
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.secondsElapsed = 3
        }
        
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.secondsElapsed = 4
            $0.$syncUp.withLock {
                $0.meetings = [
                    Meeting(id: UUID(0), syncUpId: $0.id, date: Date(timeIntervalSince1970: 1234567890), transcript: "")
                ]
            }
        }
        
        await onAppearTask.cancel()
        #expect(store.isDismissed)
    }

}
