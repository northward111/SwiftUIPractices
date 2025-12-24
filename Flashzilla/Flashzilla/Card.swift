//
//  Card.swift
//  Flashzilla
//
//  Created by hn on 2025/11/4.
//

import Foundation
import SwiftData

@Model
class Card {
    var prompt: String
    var answer: String
    
    var description: String {
        "\(id)-\(prompt)-\(answer)"
    }
    
    init(prompt: String, answer: String) {
        self.prompt = prompt
        self.answer = answer
    }
    
    static let example = Card(prompt: "Name of Henry", answer: "Henri")
    
}
