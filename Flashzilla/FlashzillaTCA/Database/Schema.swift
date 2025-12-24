import OSLog
import SQLiteData
import SwiftUI

@Table
struct Card: Hashable, Identifiable {
    let id: UUID
    var prompt: String
    var answer: String
    
    var description: String {
        "\(id)-\(prompt)-\(answer)"
    }
}

extension DependencyValues {
    mutating func bootstrapDatabase() throws {
//        @Dependency(\.context) var context
        let database = try SQLiteData.defaultDatabase()
        logger.debug(
      """
      App database:
      open "\(database.path)"
      """
        )
        var migrator = DatabaseMigrator()
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        migrator.registerMigration("Create initial tables") { db in
            try #sql(
        """
        CREATE TABLE "cards" (
          "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
          "prompt" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
          "answer" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
        ) STRICT
        """
            )
            .execute(db)
        }
        try migrator.migrate(database)
        defaultDatabase = database
//        defaultSyncEngine = try SyncEngine(
//            for: database,
//            tables: SyncUp.self,
//            Attendee.self,
//            Meeting.self
//        )
    }
}

private let logger = Logger(subsystem: "SyncUps", category: "Database")
