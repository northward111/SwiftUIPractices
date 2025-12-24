//
//  View-If.swift
//  Bookworm
//
//  Created by hn on 2025/10/24.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        }else {
            self
        }
    }
}
