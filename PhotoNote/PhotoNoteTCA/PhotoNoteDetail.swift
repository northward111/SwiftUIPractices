//
//  PhotoNoteDetail.swift
//  PhotoNoteTCA
//
//  Created by hn on 2025/12/6.
//

import ComposableArchitecture
import MapKit
import SwiftUI

@Reducer
struct PhotoNoteDetail {
    @ObservableState
    struct State: Equatable {
        let photoNote: PhotoNote
        var image: Image?
    }
    
    enum Action {
        case onAppear
        case photoLoaded(Image)
    }
    
    @Dependency(\.imageLoaderClient) var imageLoaderClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [assetID = state.photoNote.assetID] send in
                    if let image = try await imageLoaderClient.loadImage(assetID) {
                        await send(.photoLoaded(image))
                    }
                }
            case .photoLoaded(let image):
                state.image = image
                return .none
            }
        }
    }
}

struct PhotoNoteDetailView: View {
    let store: StoreOf<PhotoNoteDetail>
    var body: some View {
        VStack {
            Group {
                if let image = store.image {
                    image
                        .resizable()
                        .scaledToFit()
                }else {
                    ContentUnavailableView(
                        "No photo",
                        systemImage: "exclamationmark.circle"
                    )
                }
            }
            .frame(maxHeight: 400)
            Text(store.photoNote.name)
                .font(.headline)
            if let coordinate = store.photoNote.coordinate {
                Map(
                    initialPosition: MapCameraPosition
                        .region(
                            MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(
                                    latitudeDelta: 0.1,
                                    longitudeDelta: 0.1
                                )
                            )
                        )
                ) {
                    Marker(store.photoNote.name, coordinate: coordinate)
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle(store.photoNote.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

