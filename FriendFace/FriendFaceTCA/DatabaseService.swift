//
//  DatabaseService.swift
//  FriendFaceGRDB
//

import Foundation
import GRDB
import Dependencies


final class DatabaseService: Sendable {
    let dbQueue: DatabaseQueue

    init() throws {
        let dbURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Model.sqlite")
        dbQueue = try DatabaseQueue(path: dbURL.path)
        print("sqlite3 \"\(dbURL.path(percentEncoded: false))\"")

        try dbQueue.write { db in
            try DatabaseMigrator.migrate(db)
        }
    }
}

// MARK: - User CRUD

extension DatabaseService {
    func fetchUsers() throws -> [User] {
        try dbQueue.read { db in
            return try User.fetchUsers(db: db)
        }
    }

    func saveUsers(_ users: [User]) throws {
        try dbQueue.write { db in
            for user in users {
                try user.save(db)
                try user.saveFriends(db: db)
            }
        }
    }

    func deleteUsers(ids: [UUID]) throws {
        try dbQueue.write { db in
            try User.deleteUsers(db: db, ids: ids)
        }
    }
}

// MARK: - Dependency Injection

private enum DatabaseServiceKey: DependencyKey {
    static let liveValue: DatabaseService = {
        try! DatabaseService()
    }()
}

extension DependencyValues {
    var databaseService: DatabaseService {
        get { self[DatabaseServiceKey.self] }
        set { self[DatabaseServiceKey.self] = newValue }
    }
}
