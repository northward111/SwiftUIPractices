//
//  Models.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/24.
//

import Foundation
import GRDB
import SwiftUI


struct SyncUp: Codable, Equatable, Identifiable {
    let id: UUID
    var attendees: [Attendee] = []
    var duration: Duration = .seconds(60 * 5)
    var meetings: [Meeting] = []
    var theme: Theme = .bubblegum
    var title = ""


    var durationPerAttendee: Duration {
        duration / attendees.count
    }
}

extension SyncUp: FetchableRecord {
    init(row: Row) throws {
        id = row["id"]
        duration = row["duration"]
        theme = row["theme"]
        title = row["title"]
    }
}

extension SyncUp: PersistableRecord {
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["duration"] = duration
        container["theme"] = theme
        container["title"] = title
    }
}

extension SyncUp {
    func saveSelfMeetingsAttendees(db: Database) throws {
        try save(db)
        for attendee in self.attendees {
            try attendee.save(db)
        }
        for meeting in self.meetings {
            try meeting.save(db)
        }
    }
    static func fetchAllWithMeetingsAndAttendees(_ db: Database) throws -> [SyncUp] {
        var syncUps = try SyncUp.fetchAll(db)
        for i in syncUps.indices {
            let attendees = try Attendee.fetchAll(db, sql: """
                SELECT a.*
                FROM attendee a
                WHERE a.syncUpId = ?
            """, arguments: [syncUps[i].id])
            syncUps[i].attendees = attendees
            let meetings = try Meeting.fetchAll(db, sql: """
                SELECT m.*
                FROM meeting m
                WHERE m.syncUpId = ?
                """, arguments: [syncUps[i].id])
            syncUps[i].meetings = meetings
        }
        return syncUps
    }
    static func createTable(db: Database) throws {
        try db.create(table: "syncup") { t in
            t.primaryKey("id", .blob)
            t.column("duration", .integer).notNull()
            t.column("theme", .text).notNull()
            t.column("title", .text).notNull()
        }
    }
}


struct Attendee: Equatable, Identifiable, Codable, PersistableRecord, FetchableRecord {
    let id: UUID
    let syncUpId: UUID
    var name = ""
}

extension Attendee {
    static func createTable(db: Database) throws {
        try db.create(table: "attendee") { t in
            t.primaryKey("id", .blob)
            t.column("name", .text).notNull()
            t.column("syncUpId", .blob).notNull().references("syncup", onDelete: .cascade)
        }
    }
}

struct Meeting: Equatable, Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    let syncUpId: UUID
    let date: Date
    var transcript: String
    
}

extension Meeting {
    static func createTable(db: Database) throws {
        try db.create(table: "meeting") { t in
            t.primaryKey("id", .blob)
            t.column("date", .datetime).notNull()
            t.column("transcript", .text).notNull()
            t.column("syncUpId", .blob).notNull().references("syncup", onDelete: .cascade)
        }
    }
}


enum Theme: String, CaseIterable, Equatable, Identifiable, Codable {
    var id: Self { self }
  
    case bubblegum
    case buttercup
    case indigo
    case lavender
    case magenta
    case navy
    case orange
    case oxblood
    case periwinkle
    case poppy
    case purple
    case seafoam
    case sky
    case tan
    case teal
    case yellow


    var accentColor: Color {
        switch self {
        case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan,
                .teal, .yellow:
            return .black
        case .indigo, .magenta, .navy, .oxblood, .purple:
            return .white
        }
    }


    var mainColor: Color { Color(rawValue) }


    var name: String { rawValue.capitalized }
}

extension Theme: DatabaseValueConvertible {
    var databaseValue: DatabaseValue {
        rawValue.databaseValue
    }
    
    static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Theme? {
        guard let raw = String.fromDatabaseValue(dbValue) else { return nil }
        return Theme(rawValue: raw)
    }
}

extension Duration: @retroactive DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
        components.seconds.databaseValue
    }
    
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Duration? {
        guard let seconds = Int64.fromDatabaseValue(dbValue) else { return nil }
        return Duration.seconds(seconds)
    }
}


extension SyncUp {
    static let mock = {
        let syncUpId = SyncUp.ID()
        return SyncUp(
            id: syncUpId,
            attendees: [
                Attendee(id: Attendee.ID(), syncUpId: syncUpId, name: "Blob"),
                Attendee(id: Attendee.ID(), syncUpId: syncUpId, name: "Blob Jr."),
                Attendee(id: Attendee.ID(), syncUpId: syncUpId, name: "Blob Sr."),
            ],
            meetings: [
                Meeting(id: UUID(), syncUpId: syncUpId, date: .now, transcript: "Hello everyone.")
            ],
            title: "Point-Free Morning Sync"
        )
    }()
    
    static func makeRandom() -> Self {
        let syncUpId = SyncUp.ID()
        return SyncUp(id: UUID(), attendees: [Attendee(id: Attendee.ID(), syncUpId: syncUpId, name: "Blob")], duration: .seconds(90), title: "Random title")
    }
}
