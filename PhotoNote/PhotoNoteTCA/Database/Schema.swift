import OSLog
import CoreLocation
import SQLiteData
import SwiftUI

@Table
struct Asset: Hashable, Identifiable {
    let id: UUID
    let fileName: String
    let createdAt: Date
    var note: String
}

@Table
struct PhotoNote: Hashable, Identifiable {
    let id: UUID
    var assetID: UUID
    var name: String = ""
    var latitude: Double?
    var longitude: Double?
    
    var coordinate: CLLocationCoordinate2D? {
        if let latitude, let longitude {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }else {
            nil
        }
    }
}

extension DependencyValues {
    mutating func bootstrapDatabase() throws {
        @Dependency(\.context) var context
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
        CREATE TABLE "assets" (
          "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
          "fileName" TEXT NOT NULL ON CONFLICT REPLACE,
          "createdAt" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT CURRENT_TIMESTAMP,
          "note" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
        ) STRICT
        """
            )
            .execute(db)
            try #sql(
        """
        CREATE TABLE "photoNotes" (
          "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
          "name" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
          "assetID" TEXT NOT NULL REFERENCES "assets"("id") ON DELETE CASCADE,
          "latitude" REAL,
          "longitude" REAL
        ) STRICT
        """
            )
            .execute(db)
        }
        try migrator.migrate(database)
        defaultDatabase = database
    }
}

private let logger = Logger(subsystem: "SyncUps", category: "Database")
