//
//  FileManager-Decode.swift
//  Flashzilla
//
//  Created by hn on 2025/11/4.
//

import Foundation

extension FileManager {
    func decode<T>(filePath: any StringProtocol) -> T?  where T: Codable{
        let fullPath = URL.documentsDirectory.appending(path: filePath)
        do {
            let data = try Data(contentsOf: fullPath)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Decode error \(error.localizedDescription)")
        }
        return nil
    }
}
