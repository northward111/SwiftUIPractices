//
//  AppFeature.swift
//  PhotoNoteTCA
//
//  Created by hn on 2025/12/6.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @Reducer
    enum Path {
        case detail(PhotoNoteDetail)
    }
    @ObservableState
    struct State: Equatable {
        var photoNoteList = PhotoNoteList.State()
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case photoNoteList(PhotoNoteList.Action)
        case path(StackActionOf<Path>)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.photoNoteList, action: \.photoNoteList) {
            PhotoNoteList()
        }
        Reduce { state, action in
            switch action {
            case .path:
                return .none
            case .photoNoteList(.delegate(.gotoPhotoNoteDetail(let photoNote))):
                state.path.append(.detail(PhotoNoteDetail.State(photoNote: photoNote)))
                return .none
            case .photoNoteList:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension AppFeature.Path.State: Equatable {}

struct AppFeatureView: View {
    @Bindable var store: StoreOf<AppFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            PhotoNoteListView(store: store.scope(state: \.photoNoteList, action: \.photoNoteList))
        } destination: { store in
            switch store.case {
            case .detail(let childStore):
                PhotoNoteDetailView(store: childStore)
            }
        }
    }
}
