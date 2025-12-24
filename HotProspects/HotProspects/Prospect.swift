//
//  Prospect.swift
//  HotProspects
//
//  Created by hn on 2025/11/3.
//

import Foundation
import SwiftData

@Model
class Prospect {
    var name: String
    var emailAddress: String
    var isContacted: Bool
    var createDate: Date?
    
    init(name: String, emailAddress: String, isContacted: Bool) {
        self.name = name
        self.emailAddress = emailAddress
        self.isContacted = isContacted
    }
    
    static func example() -> Prospect {
        return Prospect(name: "Alice", emailAddress: "alice@example.com", isContacted: false)
    }
}
