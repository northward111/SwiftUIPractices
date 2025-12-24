//
//  AssetClient.swift
//  PhotoNoteTCA
//
//  Created by hn on 2025/12/6.
//

import Dependencies
import Foundation
import SQLiteData

struct AssetClient {
    var save: (UUID, Data, String) throws -> Asset
    var loadData: (UUID) throws -> Data
    var delete: (UUID) throws -> Void
}

extension DependencyValues {
    var assetClient: AssetClient {
        get { self[AssetClientKey.self] }
        set { self[AssetClientKey.self] = newValue }
    }
}

private enum AssetClientKey: DependencyKey {
    static let liveValue: AssetClient = {
        AssetClient(
            save: { id, data, note in
                try withDependencies({_ in /* no overrides */}) {
                    let deps = DependencyValues._current
                    let database = deps.defaultDatabase
                    let fileStorage = deps.fileStorage

                    let fileName = "\(id.uuidString).bin"

                    // Write file first
                    try fileStorage.save(fileName, data)

                    // Then write metadata
                    let asset = Asset(id: id, fileName: fileName, createdAt: Date(), note: note)
                    try database.write { db in
                        try Asset.upsert {
                            asset
                        }.execute(db)
                    }

                    return asset
                }
            },

            loadData: { id in
                try withDependencies({_ in /* no overrides */}) {
                    let deps = DependencyValues._current
                    let database = deps.defaultDatabase
                    guard let asset = try database.read({ db in
                        try Asset.where { $0.id.eq(id) }.fetchOne(db)
                    }) else { throw NSError() }

                    return try deps.fileStorage.load(asset.fileName)
                }
            },

            delete: { id in
                try withDependencies({_ in /* no overrides */}) {
                    let deps = DependencyValues._current
                    let database = deps.defaultDatabase
                    let fs = deps.fileStorage
                    
                    guard let asset = try database.read({ db in
                        try Asset.where { $0.id.eq(id) }.fetchOne(db)
                    }) else { return }

                    // Delete file first
                    try fs.delete(asset.fileName)

                    // Delete db record
                    try database.write { db in
                        try Asset.where { $0.id.eq(id) }.delete().execute(db)
                    }
                }
            }
        )
    }()
}
