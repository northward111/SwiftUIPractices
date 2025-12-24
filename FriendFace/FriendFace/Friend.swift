//
//  Friend.swift
//  FriendFace
//
//  Created by hn on 2025/10/28.
//

import Foundation
import SwiftData

@Model
class Friend {
    var id: UUID
    var name: String
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    static func sample() -> Friend {
        return Friend(id: UUID(), name: ["David", "Marry", "Harry", "Marc"].randomElement()!)
    }
    
}

struct FriendDTO: Codable {
    var id: UUID
    var name: String
}

extension Friend {
    var dto: FriendDTO {
        FriendDTO(id: self.id, name: self.name)
    }
    convenience init(from dto: FriendDTO) {
        self.init(id: dto.id, name: dto.name)
    }
}
