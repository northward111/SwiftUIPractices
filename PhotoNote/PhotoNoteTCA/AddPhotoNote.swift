//
//  AddPhotoNote.swift
//  PhotoNoteTCA
//
//  Created by hn on 2025/12/6.
//


import ComposableArchitecture
import PhotosUI
import SQLiteData
import SwiftUI

@Reducer
struct AddPhotoNote {
    @ObservableState
    struct State: Equatable {
        var name = ""
        var selectedPhoto: PhotosPickerItem?
        var loadedPhoto: Data?
        var lastKnownLocation: CLLocationCoordinate2D?
        
        var lastKnownLocationDescription: String {
            guard let lastKnownLocation = lastKnownLocation else { return "Unknown" }
            return "\(lastKnownLocation.latitude),\(lastKnownLocation.longitude)"
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case saveButtonTapped
        case onAppear
        case photoLoaded(Data)
        case authorizationChanged(CLAuthorizationStatus)
        case locationEvent(LocationEvent)
    }
    
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.uuid) var uuid
    @Dependency(\.assetClient) var assetClient
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .saveButtonTapped:
                guard let loadedPhoto = state.loadedPhoto, let lastKnownLocation = state.lastKnownLocation else { return .none }
                withErrorReporting {
                    let asset = try assetClient.save(uuid(), loadedPhoto, "PhotoNote")
                    let newPhotoNote = PhotoNote(id: uuid(), assetID: asset.id, name: state.name, latitude: lastKnownLocation.latitude, longitude: lastKnownLocation.longitude)
                    try database.write { db in
                        try PhotoNote.insert {
                            newPhotoNote
                        }.execute(db)
                    }
                }
                return .run { _ in
                    await dismiss()
                }
            case .binding(let bindingAction):
                switch bindingAction.keyPath {
                case \.selectedPhoto:
                    guard let selectedPhoto = state.selectedPhoto else { return .none }
                    return .run { send in
                        if let photoData = try await selectedPhoto.loadTransferable(type: Data.self) {
                            await send(.photoLoaded(photoData))
                        }
                    }
                default:
                    return .none
                }
            case .photoLoaded(let data):
                state.loadedPhoto = data
                return .none
            case .onAppear:
                locationClient.requestAuthorization()
                locationClient.startUpdatingLocation()
                return .merge(
                    .run { send in
                        for await status in locationClient.authorizationStatus() {
                            await send(.authorizationChanged(status))
                        }
                    },
                    .run {send in
                        for await event in locationClient.locationUpdates() {
                            await send(.locationEvent(event))
                        }
                    }
                )
            case .authorizationChanged:
                return .none
            case .locationEvent(let event):
                switch event {
                case let .update(coordinate, accuracy: _):
                    state.lastKnownLocation = coordinate
                    return .none
                default:
                    return .none
                }
            }
        }
    }
}

struct AddPhotoNoteView: View {
    @Bindable var store: StoreOf<AddPhotoNote>
    var body: some View {
        VStack {
            Spacer()
            PhotosPicker(selection: $store.selectedPhoto) {
                if let loadedPhoto = store.loadedPhoto, let uiImage = UIImage(data: loadedPhoto) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }else {
                    ContentUnavailableView("No Photo", systemImage: "photo.circle", description: Text("Tap to add photo."))
                }
            }
            TextField("Name", text: $store.name)
                .padding()
            Text("Location: \(store.lastKnownLocationDescription)")
            Button("Save") {
                store.send(.saveButtonTapped)
            }
            .disabled(store.name.isEmpty || store.loadedPhoto == nil || store.lastKnownLocation == nil)
        }
        .padding()
        .onAppear {
            store.send(.onAppear)
        }
    }
}
