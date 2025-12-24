//
//  File.swift
//  BucketList
//
//  Created by hn on 2025/10/30.
//

import Foundation
import SwiftUI

struct NearByPlacesResult: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int: Page]
}

struct Page: Codable, Comparable, Identifiable {
    let pageid: Int
    let title: String
    let terms: [String: [String]]?
    
    var id: Int {
        pageid
    }
    
    static func <(lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
    
    var description: String {
        terms?["description"]?.first ?? "No further information"
    }
    
    var attributedText: AttributedString {
        var result = AttributedString()
            
        var t1 = AttributedString(title)
        t1.font = .headline
        result += t1
            
        result += AttributedString(": ")
            
        var t2 = AttributedString(description)
        t2.inlinePresentationIntent = .emphasized  // italic
        result += t2
        
        return result
    }
}
