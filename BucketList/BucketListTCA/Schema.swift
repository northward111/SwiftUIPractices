import CoreLocation
import OSLog
import SQLiteData
import SwiftUI

@Table
struct Location: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double
    
    #if DEBUG
    static let example = Location(id: UUID(), name: "Buckingham Palace", description: "Lit by over 40,000 lightbulbs.", latitude: 51.501, longitude: -0.141)
    #endif
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
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
        CREATE TABLE "locations" (
          "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
          "name" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
          "description" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
          "longitude" REAL NOT NULL ON CONFLICT REPLACE DEFAULT 0.0,
          "latitude" REAL NOT NULL ON CONFLICT REPLACE DEFAULT 0.0
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
