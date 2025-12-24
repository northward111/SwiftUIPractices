//
//  ContentView.swift
//  PhotoNote
//
//  Created by hn on 2025/10/31.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \PhotoNote.name) var photoNotes: [PhotoNote]
    @State private var viewModel = PhotoList.ViewModel(photoNotes: [])
    var body: some View {
        PhotoList(viewModel: viewModel)
            .onChange(of: photoNotes, initial: true) { _, newValue in
                viewModel.photoNotes = newValue
            }
    }
}

struct PhotoNoteCell: View {
    let photoNote: PhotoNote
    var body: some View {
        Group {
            if let uiImage = photoNote.uiimageRepresentation {
                Image(uiImage: uiImage)
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
}

struct PhotoList: View {
    @Bindable var viewModel: ViewModel
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.photoNotes) { note in
                    NavigationLink(value: note) {
                        PhotoNoteCell(photoNote: note)
                    }
                }
            }
            .navigationDestination(for: PhotoNote.self) { note in
                PhotoNoteView(photoNote: note)
            }
            .navigationTitle("PhotoNotes")
            .toolbar {
                Button("Add") {
                    viewModel.showingAddView = true
                }
            }
            .sheet(isPresented: $viewModel.showingAddView) {
                AddView()
            }
        }
    }
}

#Preview {
    ContentView()
}
