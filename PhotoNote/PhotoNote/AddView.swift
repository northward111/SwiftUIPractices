//
//  AddView.swift
//  PhotoNote
//
//  Created by hn on 2025/10/31.
//

import PhotosUI
import SwiftUI

struct AddView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var loadedPhoto: Data?
    let locationFetcher = LocationFetcher()
    var body: some View {
        VStack {
            Spacer()
            PhotosPicker(selection: $selectedPhoto) {
                if let loadedPhoto, let uiImage = UIImage(data: loadedPhoto) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }else {
                    ContentUnavailableView("No Photo", systemImage: "photo.circle", description: Text("Tap to add photo."))
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                if let newValue {
                    Task {
                        do {
                            let photoData = try await newValue.loadTransferable(type: Data.self)
                            self.loadedPhoto = photoData
                        } catch {
                            print("Load photo failed: \(error.localizedDescription)")
                        }
                        
                    }
                }
            }
            TextField("Name", text: $name)
                .padding()
            Text("Location: \(locationFetcher.lastKnownLocationDescription)")
            Button("Save", action: save)
                .disabled(name.isEmpty || loadedPhoto == nil || locationFetcher.lastKnownLocation == nil)
        }
        .padding()
        .onAppear {
            locationFetcher.start()
        }
    }
    
    func save() {
        guard let loadedPhoto else { return }
        guard let lastKnownLocation = locationFetcher.lastKnownLocation else { return }
        let photoNote = PhotoNote(name: name, photo: loadedPhoto, latitude: lastKnownLocation.latitude, longitude: lastKnownLocation.longitude)
        modelContext.insert(photoNote)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddView()
}
