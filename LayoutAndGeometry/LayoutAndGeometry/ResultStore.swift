//
//  ResultStore.swift
//  LayoutAndGeometry
//
//  Created by hn on 2025/11/6.
//

import Foundation

@Observable
class ResultStore: Codable {
    static let diceOptions = [4, 6, 8, 10, 12, 20, 100]
    static let fileUrl = URL.documentsDirectory.appending(path: "ResultStore.json")
    
    var diceOption: Int {
        didSet {
            _results = []
            save()
        }
    }
    var results: [Int] {
        didSet {
            save()
        }
    }
    
    var totalRolled: Int {
        results.reduce(0) {
            $0 + $1
        }
    }
    
    
    init() {
        do {
            let data = try Data(contentsOf: ResultStore.fileUrl)
            let decoded = try JSONDecoder().decode(ResultStore.self, from: data)
            self.diceOption = decoded.diceOption
            self.results = decoded.results
        } catch {
            print("Decode error: \(error.localizedDescription)")
            self.diceOption = ResultStore.diceOptions[0]
            self.results = []
        }
    }
    
    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: ResultStore.fileUrl, options: [.atomic, .completeFileProtection])
        } catch {
            print("Encode error: \(error.localizedDescription)")
        }
    }
}
