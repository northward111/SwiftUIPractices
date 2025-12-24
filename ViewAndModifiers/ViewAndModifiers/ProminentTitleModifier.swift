//
//  ProminentTitleModifier.swift
//  ViewAndModifiers
//
//  Created by hn on 2025/7/31.
//

import Foundation
import SwiftUI

struct ProminentTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.blue)
    }
}

extension View {
    func prominentTitle() -> some View {
        modifier(ProminentTitleModifier())
    }
}
