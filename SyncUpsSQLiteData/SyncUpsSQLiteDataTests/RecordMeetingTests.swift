import ComposableArchitecture
import XCTest
@testable import SyncUpsSQLiteData

@MainActor
final class RecordMeetingTests: XCTestCase {
    func testNextButtonMovesToNextSpeaker() async {
        let syncUp = SyncUp(id: UUID(), seconds: 120, theme: .bubblegum, title: "Daily")
        let attendees = [
            Attendee(id: UUID(), syncUpID: syncUp.id, name: "Blob"),
            Attendee(id: UUID(), syncUpID: syncUp.id, name: "Blob Jr")
        ]
        let store = TestStore(initialState: RecordMeeting.State(syncUp: syncUp, attendees: attendees)) {
            RecordMeeting()
        }

        await store.send(.nextButtonTapped) {
            $0.speakerIndex = 1
            $0.secondsElapsed = 60
        }
    }

    func testTimerTickAdvancesSpeakerAtBoundary() async {
        let syncUp = SyncUp(id: UUID(), seconds: 120, theme: .bubblegum, title: "Daily")
        let attendees = [
            Attendee(id: UUID(), syncUpID: syncUp.id, name: "Blob"),
            Attendee(id: UUID(), syncUpID: syncUp.id, name: "Blob Jr")
        ]
        var initialState = RecordMeeting.State(syncUp: syncUp, attendees: attendees)
        initialState.secondsElapsed = 59

        let store = TestStore(initialState: initialState) {
            RecordMeeting()
        }

        await store.send(.timerTick) {
            $0.secondsElapsed = 60
            $0.speakerIndex = 1
        }
    }

    func testNextButtonAtEndShowsAlert() async {
        let syncUp = SyncUp(id: UUID(), seconds: 120, theme: .bubblegum, title: "Daily")
        let attendees = [
            Attendee(id: UUID(), syncUpID: syncUp.id, name: "Blob"),
            Attendee(id: UUID(), syncUpID: syncUp.id, name: "Blob Jr")
        ]
        let store = TestStore(initialState: RecordMeeting.State(syncUp: syncUp, attendees: attendees)) {
            RecordMeeting()
        }

        await store.send(.nextButtonTapped) {
            $0.speakerIndex = 1
            $0.secondsElapsed = 60
        }

        await store.send(.nextButtonTapped) {
            $0.alert = .endMeeting
        }
    }
}
