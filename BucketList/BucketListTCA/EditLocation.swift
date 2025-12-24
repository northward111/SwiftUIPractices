//
//  EditLocation.swift
//  BucketListTCA
//
//  Created by hn on 2025/12/5.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct EditLocation {
    enum LoadingState {
        case loading, loaded, failed
    }
    @ObservableState
    struct State: Equatable {
        var location: Location
        var loadingState: LoadingState = .loading
        var pages: [Page] = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onPagesRequestResult(Result<[Page], FetchPlacesError>)
        case saveButtonTapped
        case onAppear
    }
    
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.apiClient) var apiClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .saveButtonTapped:
                withErrorReporting {
                    try database.write { db in
                        try Location.upsert {
                            state.location
                        }.execute(db)
                    }
                }
                return .run { _ in
                    await dismiss()
                }
            case .onAppear:
                state.loadingState = .loading
                return .run { [coordinate = state.location.coordinate] send in
                    let result = await apiClient.fetchNearbyPlaces(coordinate)
                    await send(.onPagesRequestResult(result))
                }
            case .onPagesRequestResult(let result):
                switch result {
                case .success(let pages):
                    state.loadingState = .loaded
                    state.pages = pages
                case .failure:
                    state.loadingState = .failed
                }
                return .none
            case .binding:
                return .none
            }
        }
    }
}

struct EditLocationView: View {
    @Bindable var store: StoreOf<EditLocation>
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place name", text: $store.location.name)
                    TextField("Description", text: $store.location.description)
                }
                
                Section("Nearby") {
                    switch store.loadingState {
                    case .loading:
                        Text("Loading...")
                    case .loaded:
                        ForEach(store.pages) { page in
                            Text(page.attributedText)
                        }
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    store.send(.saveButtonTapped)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

