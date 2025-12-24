//
//  Activity.swift
//  HabitTracking
//
//  Created by hn on 2025/10/21.
//

import Foundation

let KEY_ACTIVITIES = "activities"

struct Activity: Codable, Identifiable, Hashable, Equatable {
    var id = UUID()
    let name: String
    let description: String
    var count: Int
    
    static func sample() -> Self {
        return Activity(name: "Sample", description: "This is a sample activity description.", count: 3)
    }
}

@Observable
class Activities {
    var items: [Activity] {
        didSet {
            if let data = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(data, forKey: KEY_ACTIVITIES)
            }
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: KEY_ACTIVITIES) {
            if let items = try? JSONDecoder().decode([Activity].self, from: data) {
                self.items = items
                return
            }
        }
        // still here?
        self.items = []
        self.items.append(Activity(name: "Hiking", description: "Good for health", count: 3))
    }
}
