import ComposableArchitecture
import XCTest
@testable import SyncUpsSQLiteData

@MainActor
final class AppFeatureTests: XCTestCase {
    func testSyncUpSelectionPushesDetail() async {
        let syncUp = SyncUp(id: UUID(), seconds: 15 * 60, theme: .bubblegum, title: "Daily")
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.syncUpsList(.delegate(.gotoSyncUpDetail(syncUp)))) {
            $0.path.append(.detail(SyncUpDetail.State(syncUp: syncUp)))
        }
    }

    func testStartMeetingRoutesToRecordScreen() async {
        var state = AppFeature.State()
        let syncUp = SyncUp(id: UUID(), seconds: 10 * 60, theme: .bubblegum, title: "Planning")
        let attendees = [
            Attendee(id: UUID(), syncUpID: syncUp.id, name: "Blob"),
            Attendee(id: UUID(), syncUpID: syncUp.id, name: "Blob Jr")
        ]

        state.path.append(.detail(SyncUpDetail.State(syncUp: syncUp)))
        let store = TestStore(initialState: state) {
            AppFeature()
        }

        guard let detailID = store.state.path.ids.last else {
            XCTFail("Detail path missing")
            return
        }

        await store.send(
            .path(
                .element(
                    id: detailID,
                    action: .detail(.delegate(.gotoStartMeeting(syncUp, attendees: attendees)))
                )
            )
        ) {
            $0.path.append(.record(RecordMeeting.State(syncUp: syncUp, attendees: attendees)))
        }
    }
}
