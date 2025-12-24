//
//  FileStorageClient.swift
//  PhotoNoteTCA
//
//  Created by hn on 2025/12/6.
//

import Dependencies
import Foundation

struct FileStorageClient {
    var load: (String) throws -> Data
    var save: (String, Data) throws -> Void
    var delete: (String) throws -> Void
    var fileURL: (String) -> URL
}

extension DependencyValues {
    var fileStorage: FileStorageClient {
        get { self[FileStorageClientKey.self] }
        set { self[FileStorageClientKey.self] = newValue }
    }
}

private enum FileStorageClientKey: DependencyKey {
    static let liveValue: FileStorageClient = {
        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AppData")

        // ensure directory
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)

        return FileStorageClient(
            load: { fileName in
                try Data(contentsOf: baseURL.appendingPathComponent(fileName))
            },
            save: { fileName, data in
                try data.write(to: baseURL.appendingPathComponent(fileName), options: .atomic)
            },
            delete: { fileName in
                try? FileManager.default.removeItem(at: baseURL.appendingPathComponent(fileName))
            },
            fileURL: { fileName in
                baseURL.appendingPathComponent(fileName)
            }
        )
    }()
}
