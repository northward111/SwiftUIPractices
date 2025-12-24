//
//  Mission.swift
//  Moonshot
//
//  Created by hn on 2025/10/13.
//

import Foundation

struct Mission: Codable, Equatable, Identifiable, Hashable {
    
    struct CrewRole: Codable, Hashable {
        let name: String
        let role: String
    }
    
    let id: Int
    let launchDate: Date?
    let crew: [CrewRole]
    let description: String
    
    var displayName: String {
        "Apollo \(id)"
    }
    
    var image: String {
        "apollo\(id)"
    }
    
    var formattedLaunchDate: String {
        launchDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A"
    }
    
    var formattedLaunchDateLabel: String {
        launchDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not available"
    }
}
