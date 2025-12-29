//
//  ContentView.swift
//  HotProspects
//
//  Created by hn on 2025/11/1.
//

import UserNotifications
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Everyone", systemImage: "person.3") {
                ProspectsView(filter: .none)
            }
            Tab("Contaced", systemImage: "checkmark.circle") {
                ProspectsView(filter: .contacted)
            }
            Tab("Uncontacted", systemImage: "questionmark.diamond") {
                ProspectsView(filter: .uncontacted)
            }
            Tab("Me", systemImage: "person.crop.square") {
                MeView()
            }
        }
    }
}

#Preview {
    ContentView()
}
