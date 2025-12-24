//
//  ContentView.swift
//  SnowSeeker
//
//  Created by hn on 2025/11/6.
//

import SwiftUI

struct ContentView: View {
    enum SortOrder {
    case none, alphabetical, country
    }
    let resorts: [Resort] = Bundle.main.decode("resorts.json")
    @State private var searchText = ""
    @State private var favorites = Favorites()
    @State private var sortOrder = SortOrder.none
    var filteredResorts: [Resort] {
        var result: [Resort]
        if searchText.isEmpty {
            result = resorts
        }else {
            result = resorts.filter { $0.name.localizedStandardContains(searchText) }
        }
        switch sortOrder {
        case .none: break
        case .alphabetical:
            result = result.sorted(by: { lhs, rhs in
                lhs.name < rhs.name
            })
        case .country:
            result = result.sorted(by: { lhs, rhs in
                lhs.country < rhs.country
            })
        }
        return result
    }
    var body: some View {
        NavigationSplitView {
            List(filteredResorts) { resort in
                NavigationLink(value: resort) {
                    HStack {
                        Image(resort.country)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 25)
                            .clipShape(
                                .rect(cornerRadius: 5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.black, lineWidth: 1)
                            )

                        VStack(alignment: .leading) {
                            Text(resort.name)
                                .font(.headline)
                            Text("\(resort.runs) runs")
                                .foregroundStyle(.secondary)
                        }
                        if favorites.contains(resort) {
                            Spacer()
                            Image(systemName: "heart.fill")
                            .accessibilityLabel("This is a favorite resort")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Resorts")
            .navigationDestination(for: Resort.self) { resort in
                ResortView(resort: resort)
            }
            .searchable(text: $searchText, prompt: "Search for a resort")
            .toolbar {
                Menu {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Default").tag(SortOrder.none)
                        Text("Alphabetical").tag(SortOrder.alphabetical)
                        Text("Country").tag(SortOrder.country)
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        } detail: {
            WelcomeView()
        }
        .environment(favorites)

    }
}

#Preview {
    ContentView()
}
