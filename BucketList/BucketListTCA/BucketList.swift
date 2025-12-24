//
//  ContentView.swift
//  BucketListTCA
//
//  Created by hn on 2025/12/5.
//

import ComposableArchitecture

import MapKit
import SQLiteData
import SwiftUI

@Reducer
struct BucketList {
    static let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(
                latitudeDelta: 10,
                longitudeDelta: 10
            )
        )
    )
    @Reducer
    enum Destination {
        case alert(AlertState<Alert>)
        case edit(EditLocation)
        
        @CasePathable
        enum Alert {
            case retryButtonTapped
        }
    }
    @ObservableState
    struct State: Equatable {
        @FetchAll
        var locations: [Location]
        var selectedPlace: Location?
        var isUnlocked = false
        var usingHybrid = false
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case unlockButtonTapped
        case authenticationResult(Result<Void, any Error>)
        case locationButtonLongPressed(Location)
        case locationTapped(CLLocationCoordinate2D)
        case mapModeToggleButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.authenticationClient) var authenticationClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .mapModeToggleButtonTapped:
                state.usingHybrid.toggle()
                return .none
            case .locationTapped(let coordinate):
                let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                withErrorReporting {
                    try database.write { db in
                        try Location.insert {
                            newLocation
                        }.execute(db)
                    }
                }
                return .none
            case .locationButtonLongPressed(let location):
                state.destination = .edit(EditLocation.State(location: location))
                return .none
            case .authenticationResult(let result):
                switch result {
                case .success:
                    state.isUnlocked = true
                case .failure(let error):
                    state.destination = .alert(.error(message: error.localizedDescription))
                }
                return .none
            case .unlockButtonTapped:
                return .run { send in
                    let result = await authenticationClient.authenticate()
                    await send(.authenticationResult(result))
                }
            case .destination(.presented(.alert(.retryButtonTapped))):
                return .run { send in
                    let result = await authenticationClient.authenticate()
                    await send(.authenticationResult(result))
                }
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension BucketList.Destination.State: Equatable {}

extension AlertState where Action == BucketList.Destination.Alert {
    static func error(message: String) -> Self {
        AlertState {
            TextState("Error")
        } actions: {
            ButtonState(action: .retryButtonTapped) {
                TextState("Retry")
            }
            ButtonState (role: .cancel) {
                TextState("Cancel")
            }
        } message: {
            TextState(message)
        }
    }
}

struct BucketListView: View {
    @Bindable var store: StoreOf<BucketList>
    var body: some View {
        Group {
            if store.isUnlocked {
                ZStack(alignment: .topTrailing) {
                    MapReader { proxy in
                        Map(initialPosition: BucketList.startPosition) {
                            ForEach(store.locations) { location in
                                Annotation(location.name, coordinate: location.coordinate) {
                                    Button(action: {}) {
                                        Image(systemName: "star.circle")
                                            .resizable()
                                            .foregroundStyle(.red)
                                            .frame(width: 44, height: 44)
                                            .background(.white)
                                            .clipShape(.circle)
                                            .onLongPressGesture {
                                                store.send(.locationButtonLongPressed(location))
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .mapStyle(store.usingHybrid ? .hybrid : .standard)
                        .onTapGesture { position in
                            if let coordiate = proxy.convert(position, from: .local) {
                                store.send(.locationTapped(coordiate))
                            }
                        }
                        .sheet(item: $store.scope(state: \.destination?.edit, action: \.destination.edit)) { store in
                            EditLocationView(store: store)
                        }
                    }
                    Button("Standard/Hybrid") {
                        store.send(.mapModeToggleButtonTapped)
                    }
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                    .padding()
                    
                }
                
            }else {
                Button("Click to unlock") {
                    store.send(.unlockButtonTapped)
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

//#Preview {
//    ContentView()
//}
