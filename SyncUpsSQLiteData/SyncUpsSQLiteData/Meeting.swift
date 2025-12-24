//
//  Meeting.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/25.
//

import SwiftUI

struct MeetingView: View {
    let meeting: Meeting
    let attendees: [Attendee]
    var body: some View {
        Form {
            Section {
                ForEach(attendees) { attendee in
                    Text(attendee.name)
                }
            } header: {
                Text("Attendees")
            }
            Section {
                Text(meeting.transcript)
            } header: {
                Text("Transcript")
            }
        }
        .navigationTitle(Text(meeting.date, style: .date))
    }
}

//#Preview {
//  MeetingView(meeting: SyncUp.mock.meetings[0], attendees: [])
//}
