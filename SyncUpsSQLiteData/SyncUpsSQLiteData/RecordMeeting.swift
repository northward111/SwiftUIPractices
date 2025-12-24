//
//  RecordMeeting.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/25.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct RecordMeeting {
    @ObservableState
    struct State: Equatable {
        var secondsElapsed = 0
        var speakerIndex = 0
        let syncUp: SyncUp
        let attendees: [Attendee]
        var transcript = ""
        @Presents var alert: AlertState<Action.Alert>?
        
        var durationRemaining: Duration {
            syncUp.duration - .seconds(secondsElapsed)
        }
        
        var durationPerAttendee: Duration {
            syncUp.seconds.duration / attendees.count
        }
    }
    
    enum Action {
        case endMeetingButtonTapped
        case nextButtonTapped
        case onAppear
        case timerTick
        case alert(PresentationAction<Alert>)
        
        enum Alert {
            case discardMeeting
            case saveMeeting
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.date.now) var now
    @Dependency(\.uuid) var uuid
    @Dependency(\.continuousClock) var clock
    @Dependency(\.defaultDatabase) var database
    
    var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .alert(.presented(.discardMeeting)):
                return .run { _ in
                    await dismiss()
                }
            case .alert(.presented(.saveMeeting)):
                saveMeeting(state: &state)
                return .run { _ in
                    await dismiss()
                }
            case .alert:
                return .none
            case .endMeetingButtonTapped:
                state.alert = .endMeeting
                return .none
            case .nextButtonTapped:
                guard state.speakerIndex < state.attendees.count - 1 else {
                    state.alert = .endMeeting
                    return .none
                }
                state.speakerIndex += 1
                state.secondsElapsed = state.speakerIndex * Int(state.durationPerAttendee.components.seconds)
                return .none
            case .onAppear:
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerTick)
                    }
                }
            case .timerTick:
                guard state.alert == nil else {
                    return .none
                }
                state.secondsElapsed += 1
                let secondsPerAttendee = Int(
                    state.durationPerAttendee.components.seconds
                )
                if state.secondsElapsed.isMultiple(of: secondsPerAttendee) {
                    if state.secondsElapsed == state.syncUp.duration.components.seconds {
                        saveMeeting(state: &state)
                        return .run { _ in
                            await dismiss()
                        }
                    }
                    state.speakerIndex += 1
                }
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    func saveMeeting(state: inout State) {
        withErrorReporting {
            try database.write { db in
                try Meeting.insert {
                    Meeting.Draft(syncUpID: state.syncUp.id, date: now, transcript: state.transcript)
                }.execute(db)
            }
        }
    }
}

extension AlertState where Action == RecordMeeting.Action.Alert {
    static var endMeeting: Self {
        Self {
            TextState("End meeting?")
        } actions: {
            ButtonState(action: .saveMeeting) {
                TextState("Save and end")
            }
            ButtonState(role: .destructive, action: .discardMeeting) {
                TextState("Discard")
            }
            ButtonState(role: .cancel) {
                TextState("Resume")
            }
        } message: {
            TextState(
                "You are ending the meeting early. What would you like to do?"
            )
        }
    }
}

struct RecordMeetingView: View {
    @Bindable var store: StoreOf<RecordMeeting>
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(store.syncUp.theme.mainColor)

            VStack {
                MeetingHeaderView(
                    secondsElapsed: store.secondsElapsed,
                    durationRemaining: store.durationRemaining,
                    theme: store.syncUp.theme
                )
                MeetingTimerView(
                    theme: store.syncUp.theme,
                    attendees: store.attendees,
                    speakerIndex: store.speakerIndex
                )
                MeetingFooterView(
                    totalSpeakers: store.attendees.count,
                    nextButtonTapped: {
                        store.send(.nextButtonTapped)
                    },
                    speakerIndex: store.speakerIndex
                )
            }
        }
        .padding()
        .foregroundStyle(store.syncUp.theme.accentColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("End meeting") {
                    store.send(.endMeetingButtonTapped)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            store.send(.onAppear)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

struct MeetingHeaderView: View {
    let secondsElapsed: Int
    let durationRemaining: Duration
    let theme: Theme
    
    
    var body: some View {
        VStack {
            ProgressView(value: progress)
                .progressViewStyle(MeetingProgressViewStyle(theme: theme))
            HStack {
                VStack(alignment: .leading) {
                    Text("Time Elapsed")
                        .font(.caption)
                    Label(
                        Duration.seconds(secondsElapsed).formatted(.units()),
                        systemImage: "hourglass.bottomhalf.fill"
                    )
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Time Remaining")
                        .font(.caption)
                    Label(
                        durationRemaining.formatted(.units()),
                        systemImage: "hourglass.tophalf.fill"
                    )
                    .font(.body.monospacedDigit())
                    .labelStyle(.trailingIcon)
                }
            }
        }
        .padding([.top, .horizontal])
    }
    
    private var totalDuration: Duration {
        .seconds(secondsElapsed) + durationRemaining
    }
    
    
    private var progress: Double {
        guard totalDuration > .seconds(0) else { return 0 }
        return Double(secondsElapsed) / Double(totalDuration.components.seconds)
    }
}

struct MeetingProgressViewStyle: ProgressViewStyle {
    var theme: Theme


    func makeBody(configuration: ProgressViewStyleConfiguration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.accentColor)
                .frame(height: 20)


            ProgressView(configuration)
                .tint(theme.mainColor)
                .frame(height: 12)
                .padding(.horizontal)
        }
    }
}

struct MeetingTimerView: View {
    let theme: Theme
    let attendees: [Attendee]
    let speakerIndex: Int


    var body: some View {
        Circle()
            .strokeBorder(lineWidth: 24)
            .overlay {
                VStack {
                    Group {
                        if speakerIndex < attendees.count {
                            Text(attendees[speakerIndex].name)
                        } else {
                            Text("Someone")
                        }
                    }
                    .font(.title)
                    Text("is speaking")
                    Image(systemName: "mic.fill")
                        .font(.largeTitle)
                        .padding(.top)
                }
                .foregroundStyle(theme.accentColor)
            }
            .overlay {
                ForEach(
                    Array(attendees.enumerated()),
                    id: \.element.id
                ) {
                    index,
                    attendee in
                    if index < speakerIndex + 1 {
                        SpeakerArc(
                            totalSpeakers: attendees.count,
                            speakerIndex: index
                        )
                        .rotation(Angle(degrees: -90))
                        .stroke(theme.mainColor, lineWidth: 12)
                    }
                }
            }
            .padding(.horizontal)
    }
}

struct SpeakerArc: Shape {
    let totalSpeakers: Int
    let speakerIndex: Int


    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 24
        let radius = diameter / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
        }
    }


    private var degreesPerSpeaker: Double {
        360 / Double(totalSpeakers)
    }
    private var startAngle: Angle {
        Angle(degrees: degreesPerSpeaker * Double(speakerIndex) + 1)
    }
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + degreesPerSpeaker - 1)
    }
}

struct MeetingFooterView: View {
    let totalSpeakers: Int
    var nextButtonTapped: () -> Void
    let speakerIndex: Int


    var body: some View {
        VStack {
            HStack {
                if speakerIndex < totalSpeakers - 1 {
                    Text(
                        "Speaker \(speakerIndex + 1) of \(totalSpeakers)"
                    )
                } else {
                    Text("No more speakers.")
                }
                Spacer()
                Button(action: nextButtonTapped) {
                    Image(systemName: "forward.fill")
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
}

//#Preview {
//    NavigationStack {
//        RecordMeetingView(
//            store: Store(
//                initialState: RecordMeeting.State(syncUp: Shared(value: .mock))
//            ) {
//                RecordMeeting()
//            }
//        )
//    }
//}

