//
//  ContentView.swift
//  ViewAndModifiers
//
//  Created by hn on 2025/7/30.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .prominentTitle()
                .padding()
                .background(.red)
                .padding()
                .background(.blue)
                .padding()
                .background(.green)
            Button("Click to show type") {
                print(type(of: self.body))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
