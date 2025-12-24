//
//  ContentView.swift
//  BucketList
//
//  Created by hn on 2025/10/30.
//

import LocalAuthentication
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(
                latitudeDelta: 10,
                longitudeDelta: 10
            )
        )
    )
    var body: some View {
        Group {
            if viewModel.isUnlocked {
                ZStack(alignment: .topTrailing) {
                    MapReader { proxy in
                        Map(initialPosition: startPosition) {
                            ForEach(viewModel.locations) { location in
                                Annotation(location.name, coordinate: location.coordinate) {
                                    Button(action: {}) {
                                        Image(systemName: "star.circle")
                                            .resizable()
                                            .foregroundStyle(.red)
                                            .frame(width: 44, height: 44)
                                            .background(.white)
                                            .clipShape(.circle)
                                            .onLongPressGesture {
                                                viewModel.selectedPlace = location
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .mapStyle(viewModel.usingHybrid ? .hybrid : .standard)
                        .onTapGesture { position in
                            if let coordiate = proxy.convert(position, from: .local) {
                                viewModel.addLocation(at: coordiate)
                            }
                        }
                        .sheet(item: $viewModel.selectedPlace) { place in
                            EditView(location: place) { newLocation in
                                viewModel.update(location: newLocation)
                            }
                        }
                    }
                    Button("Standard/Hybrid", action: viewModel.toggleMapStyle)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                        .padding()
                    
                }
                
            }else {
                Button("Click to unlock", action: viewModel.authenticate)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
        }
        .alert("Error", isPresented: $viewModel.showingAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Retry", action: viewModel.authenticate)
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    ContentView()
}
