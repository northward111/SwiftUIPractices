//
//  ResortView.swift
//  SnowSeeker
//
//  Created by hn on 2025/11/7.
//

import SwiftUI

struct ResortView: View {
    let resort: Resort
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(Favorites.self) var favorites
    @State private var selectedFacility: Facility?
    @State private var showingFacility = false
    var isFavorite: Bool {
        favorites.contains(resort)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    Image(decorative: resort.id)
                        .resizable()
                        .scaledToFit()
                    Text(resort.imageCredit)
                        .font(.caption2.bold())
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .foregroundStyle(.white)
                        .padding([.bottom, .trailing], 10)
                }
                
                HStack {
                    if horizontalSizeClass == .compact && dynamicTypeSize > .large {
                        VStack(spacing: 10) {
                            ResortDetailsView(resort: resort)
                        }
                        VStack(spacing: 10) { SkiDetailsView(resort: resort) }
                    }else {
                        ResortDetailsView(resort: resort)
                        SkiDetailsView(resort: resort)
                    }
                }
                .padding(.vertical)
                .background(.primary.opacity(0.1))
                Group {
                    Text(resort.description)
                        .padding(.vertical)

                    Text("Facilities")
                        .font(.headline)

                    HStack {
                        ForEach(resort.facilityTypes) { facility in
                            Button {
                                selectedFacility = facility
                                showingFacility = true
                            } label: {
                                facility.icon
                                    .font(.title)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                Button(
                    isFavorite ? "Remove from Favorites" : "Add to Favorites"
                ) {
                    if isFavorite {
                        favorites.remove(resort)
                    } else {
                        favorites.add(resort)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .navigationTitle("\(resort.name), \(resort.country)")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            selectedFacility?.name ?? "More information",
            isPresented: $showingFacility,
            presenting: selectedFacility
        ) {
            _ in
        } message: { facility in
            Text(facility.description)
        }
    }
}

#Preview {
    ResortView(resort: .example)
        .environment(Favorites())
}
