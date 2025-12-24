//
//  String-SemanticEmpty.swift
//  Bookworm
//
//  Created by hn on 2025/10/24.
//

import Foundation

extension String {
    var isSemanticallyEmpty: Bool {
        if self.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
}
