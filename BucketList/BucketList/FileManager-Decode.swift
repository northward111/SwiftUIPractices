//
//  FileManager-Decode.swift
//  BucketList
//
//  Created by hn on 2025/10/30.
//

import Foundation

extension FileManager {
    func decodeFromDocuments<T: Codable>(relativePath: any StringProtocol) throws -> T {
        let url = URL.documentsDirectory.appending(path: relativePath)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
