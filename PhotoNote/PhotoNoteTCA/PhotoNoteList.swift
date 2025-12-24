//
//  PhotoNoteList.swift
//  PhotoNoteTCA
//
//  Created by hn on 2025/12/6.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct PhotoNoteList {
    @Reducer
    enum Destination {
        case add(AddPhotoNote)
    }
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        @FetchAll(PhotoNote.order(by: \.name))
        var photoNotes: [PhotoNote]
        var images: [UUID: Image] = [:]
        
        var notes: IdentifiedArrayOf<PhotoNote> {
            IdentifiedArray(uniqueElements: photoNotes)
        }
    }
    
    enum Action {
        case addButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case photoNoteTapped(PhotoNote)
        case delegate(Delegate)
        case _internalImageLoaded(UUID, Image)
        case onAppear
        enum Delegate {
            case gotoPhotoNoteDetail(PhotoNote)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.imageLoaderClient) var imageLoaderClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let idsInDict = Set(state.images.keys)
                let ids = Set(state.notes.ids)
                let added = ids.subtracting(idsInDict)
                let removed = idsInDict.subtracting(ids)
                return loadImages(state: &state, added: added, removed: removed)
            case let ._internalImageLoaded(id, image):
                state.images[id] = image
                return .none
            case .destination:
                return .none
            case .delegate:
                return .none
            case .addButtonTapped:
                state.destination = .add(AddPhotoNote.State())
                return .none
            case .photoNoteTapped(let photoNote):
                return .send(.delegate(.gotoPhotoNoteDetail(photoNote)))
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .onChange(of: \.photoNotes) {
            oldValue,
            newValue in
            Reduce {
                state,
                _ in
                // Load images for new notes
                let newIds = Set(newValue.map(\.id))
                let oldIds = Set(oldValue.map(\.id))

                let added = newIds.subtracting(oldIds)
                let removed = oldIds.subtracting(newIds)

                return loadImages(state: &state, added: added, removed: removed)
            }
        }
    }
    
    func loadImages(state: inout State ,added: Set<UUID>, removed: Set<UUID> = []) -> EffectOf<Self> {
        // Remove images no longer needed
        for id in removed {
            state.images[id] = nil
        }

        // Kick off async loads for new images
        return .run { [added, notes = state.notes] send in
            for id in added {
                if let image = try await imageLoaderClient.loadImage(notes[id: id]!.assetID) {
                    await send(._internalImageLoaded(id, image))
                }
            }
        }
    }
}

extension PhotoNoteList.Destination.State: Equatable {}

struct PhotoNoteCell: View {
    let photoNote: PhotoNote
    let image: Image?
    var body: some View {
        VStack {
            Group {
                if let image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }else {
                    Text("No image data")
                }
            }
            
            Text(photoNote.name)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        
    }
}

struct PhotoNoteListView: View {
    @Bindable var store: StoreOf<PhotoNoteList>
    var body: some View {
        List {
            ForEach(store.photoNotes) { note in
                Button {
                    store.send(.photoNoteTapped(note))
                } label: {
                    PhotoNoteCell(photoNote: note, image: store.images[note.id])
                }
            }
        }
        .navigationTitle("PhotoNotes")
        .toolbar {
            Button("Add") {
                store.send(.addButtonTapped)
            }
        }
        .sheet(item: $store.scope(state: \.destination?.add, action: \.destination.add)) { addStore in
            NavigationStack {
                AddPhotoNoteView(store: addStore)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
