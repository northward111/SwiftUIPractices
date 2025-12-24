//
//  User.swift
//  FriendFace
//
//  Created by hn on 2025/10/28.
//

import Foundation
import SwiftData

@Model
class User {
    var id: UUID
    var isActive: Bool
    var name: String
    var age: Int
    var company: String
    var email: String
    var address: String
    var about: String
    var registered: Date
    var tags: [String]
    var friends: [Friend]
    
    init(id: UUID, isActive: Bool, name: String, age: Int, company: String, email: String, address: String, about: String, registered: Date, tags: [String], friends: [Friend]) {
        self.id = id
        self.isActive = isActive
        self.name = name
        self.age = age
        self.company = company
        self.email = email
        self.address = address
        self.about = about
        self.registered = registered
        self.tags = tags
        self.friends = friends
    }
    
    static func sample() -> User {
        return User(id: UUID(), isActive: false, name: "John", age: 25, company: "Apple Inc.", email: "john@apple.com", address: "Mountain View Street", about: "A great person for the whole humankind.", registered: .now, tags: ["Kind", "Wholesome"], friends: [.sample(), .sample(), .sample()])
    }
}

struct UserDTO: Codable {
    var id: UUID
    var isActive: Bool
    var name: String
    var age: Int
    var company: String
    var email: String
    var address: String
    var about: String
    var registered: Date
    var tags: [String]
    var friends: [FriendDTO]
}

extension User {
    convenience init(from dto: UserDTO) {
        self.init(id: dto.id, isActive: dto.isActive, name: dto.name, age: dto.age, company: dto.company, email: dto.email, address: dto.address, about: dto.about, registered: dto.registered, tags: dto.tags, friends: dto.friends.map{Friend(from: $0)})
    }
    
    var dto: UserDTO {
        UserDTO(id: id, isActive: isActive, name: name, age: age, company: company, email: email, address: address, about: about, registered: registered, tags: tags, friends: friends.map{$0.dto})
    }
}
