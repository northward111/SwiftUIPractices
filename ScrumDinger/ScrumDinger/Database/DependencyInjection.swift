//
//  DatabaseService.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/29.
//

import Dependencies

// MARK: - Dependency Injection

private enum AppDatabaseKey: DependencyKey {
    static let liveValue: AppDatabase = .shared
    static var testValue: AppDatabase = .empty()
}

extension DependencyValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}
