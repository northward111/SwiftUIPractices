//
//  AddressView.swift
//  CupcakeCorner
//
//  Created by hn on 2025/10/23.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddressFeature {
    static let KEY_STREET_ADDRESS = "streetAddress"
    @ObservableState
    struct State: Equatable {
        var name = ""
        var streetAddress = ""
        var city = ""
        var zip = ""
        
        var hasValidAddress: Bool {
            if name.isEmpty || city.isEmpty || zip.isEmpty {
                return false
            }
            if streetAddress.trimmingCharacters(in: .whitespaces).isEmpty {
                return false
            }
            return true
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case delegate(Delegate)
        case checkoutButtonTapped
        
        enum Delegate {
            case gotoCheckout(State)
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let streetAddress = UserDefaults.standard.string(forKey: AddressFeature.KEY_STREET_ADDRESS) {
                    state.streetAddress = streetAddress
                }
            case .checkoutButtonTapped:
                return .send(.delegate(.gotoCheckout(state)))
            case .binding(let bindingAction):
                switch bindingAction.keyPath {
                case \.streetAddress:
                    return .run { [streetAddress = state.streetAddress] _ in
                        UserDefaults.standard.set(streetAddress, forKey: AddressFeature.KEY_STREET_ADDRESS)
                    }
                default:
                    break
                }
            case .delegate:
                break
            }
            
            return .none
        }
    }
}


struct AddressView: View {
    @Bindable var store: StoreOf<AddressFeature>
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $store.name)
                TextField("Street Address", text: $store.streetAddress)
                TextField("City", text: $store.city)
                TextField("Zip Code", text: $store.zip)
            }
            
            Section {
                Button("Check out") {
                    store.send(.checkoutButtonTapped)
                }
            }
            .disabled(store.hasValidAddress == false)
        }
        .navigationTitle("Delivery details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    
}

//#Preview {
//    AddressView(order: Order())
//}
