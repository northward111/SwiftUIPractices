//
//  Models.swift
//  FriendFaceGRDB
//

import Foundation
import GRDB

struct Friend: Codable, FetchableRecord, Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    
    static func sample() -> Friend {
        Friend(id: UUID(), name: ["David", "Marry", "Harry", "Marc"].randomElement()!)
    }
}

extension Friend: PersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id.uuidString
        container["name"] = name
    }
}

struct User: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var isActive: Bool
    var name: String
    var age: Int
    var company: String
    var email: String
    var address: String
    var about: String
    var registered: Date
    var tags: [String]

    // friends are stored via a junction table: userFriend(userId, friendId)
    var friends: [Friend] = []
    
    init(id: UUID, isActive: Bool, name: String, age: Int, company: String, email: String, address: String, about: String, registered: Date, tags: [String], friends: [Friend]) {
        self.id = id
        self.isActive = isActive
        self.name = name
        self.age = age
        self.company = company
        self.email = email
        self.address = address
        self.about = about
        self.registered = registered
        self.tags = tags
        self.friends = friends
    }
    
    static func sample() -> User {
        User(
            id: UUID(),
            isActive: true,
            name: "Jon",
            age: 18,
            company: "CITI",
            email: "jon@citi.com",
            address: "129, Downing street",
            about: "A great employee",
            registered: Date(),
            tags: ["Kind", "Efficient"],
            friends: (0..<4).map { _ in Friend.sample() }
        )
    }
}

extension User: PersistableRecord {
    // first, for id with UUID type, save the corresponding uuisString to the database
    // second, ignore friends field when saving
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id.uuidString
        container["isActive"] = isActive
        container["name"] = name
        container["age"] = age
        container["company"] = company
        container["email"] = email
        container["address"] = address
        container["about"] = about
        container["registered"] = registered
        container["tags"] = try? JSONEncoder().encode(tags)
        // DO NOT encode friends — handled via junction table separately
    }
}

extension User: FetchableRecord {
    // ignore friends field when instantiating a model from database record
    init(row: Row) throws {
        id = row["id"]
        isActive = row["isActive"]
        name = row["name"]
        age = row["age"]
        company = row["company"]
        email = row["email"]
        address = row["address"]
        about = row["about"]
        registered = row["registered"]

        if let tagsData: String = row["tags"],
           let data = tagsData.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            tags = decoded
        } else {
            tags = []
        }

        // friends are NOT stored in this table
        friends = []
    }
}

// MARK: - GRDB Table Definitions and Migrations

struct DatabaseMigrator {
    static func migrate(_ db: Database) throws {
        // User table
        try db.create(table: "user", ifNotExists: true) { t in
            t.column("id", .text).primaryKey()
            t.column("isActive", .boolean).notNull()
            t.column("name", .text).notNull()
            t.column("age", .integer).notNull()
            t.column("company", .text).notNull()
            t.column("email", .text).notNull()
            t.column("address", .text).notNull()
            t.column("about", .text).notNull()
            t.column("registered", .datetime).notNull()
            t.column("tags", .text) // can be JSON encoded
        }

        // Friend table
        try db.create(table: "friend", ifNotExists: true) { t in
            t.column("id", .text).primaryKey()
            t.column("name", .text).notNull()
        }

        // Junction table for many-to-many relationship
        try db.create(table: "userFriend", ifNotExists: true) { t in
            t.column("userId", .text).notNull().indexed().references("user", onDelete: .cascade)
            t.column("friendId", .text).notNull().indexed().references("friend", onDelete: .cascade)
            t.primaryKey(["userId", "friendId"])
        }
    }
}

// MARK: - Helper functions for user-friend relationship

extension User {
    func saveFriends(db: Database) throws {
        for friend in friends {
            try friend.save(db)
            try db.execute(sql: "INSERT OR IGNORE INTO userFriend (userId, friendId) VALUES (?, ?)", arguments: [id.uuidString, friend.id.uuidString])
        }
    }
    
    static func fetchUsers(db: Database) throws -> [User] {
        var users = try User.fetchAll(db)
        for i in users.indices {
            let friends = try Friend.fetchAll(db, sql: """
                SELECT f.*
                FROM friend f
                JOIN userFriend uf ON uf.friendId = f.id
                WHERE uf.userId = ?
            """, arguments: [users[i].id.uuidString])
            users[i].friends = friends
        }
        return users
    }
    
    static func deleteUsers(db: Database, ids: [UUID]) throws {
        for id in ids {
            try db.execute(sql: "DELETE FROM userFriend WHERE userId = ?", arguments: [id.uuidString])
            try User.deleteOne(db, id: id)
        }
    }
}
