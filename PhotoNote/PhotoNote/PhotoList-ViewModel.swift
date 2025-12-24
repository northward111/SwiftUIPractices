//
//  ContentView-ViewModel.swift
//  PhotoNote
//
//  Created by hn on 2025/10/31.
//

import Foundation

extension PhotoList {
    @Observable
    class ViewModel {
        var photoNotes: [PhotoNote]
        var showingAddView = false
        
        init(photoNotes: [PhotoNote]) {
            self.photoNotes = photoNotes
        }
    }
}
