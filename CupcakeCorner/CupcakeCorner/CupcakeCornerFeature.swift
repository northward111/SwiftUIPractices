//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by hn on 2025/10/23.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CupcakeCornerFeature {
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    @ObservableState
    struct State: Equatable {
        var type = 0
        var quantity = 3
        var extraFrosting = false
        var addSprinkles = false
        var specialRequestEnabled = false
        var path = StackState<Path.State>()
        
        var cost: Decimal {
            var cost = Decimal(quantity) * 2
            cost += Decimal(type) / 2
            if extraFrosting {
                cost += Decimal(quantity)
            }
            if addSprinkles {
                cost += Decimal(quantity) / 2
            }
            return cost
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case deliveryDetailsButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(let bindingAction):
                switch bindingAction.keyPath {
                case \.specialRequestEnabled:
                    if state.specialRequestEnabled == false {
                        state.extraFrosting = false
                        state.addSprinkles = false
                    }
                default:
                    break
                }
            case .path(.element(id: _, action: .address(.delegate(.gotoCheckout(let addressState))))):
                let order = Order.init(cornerState: state, addressState: addressState)
                state.path.append(.checkout(.init(cost: state.cost, order: order)))
            case .path:
                break
            case .deliveryDetailsButtonTapped:
                state.path.append(.address(.init()))
            }
            return .none
        }
        .forEach(\.path, action: \.path)
    }
}

extension CupcakeCornerFeature {
    @Reducer
    enum Path {
        case address(AddressFeature)
        case checkout(CheckoutFeature)
    }
}

extension CupcakeCornerFeature.Path.State: Equatable {}



struct ContentView: View {
    @Bindable var store: StoreOf<CupcakeCornerFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Form {
                Section {
                    Picker("Select your cake type", selection: $store.type) {
                        ForEach(CupcakeCornerFeature.types.indices, id: \.self) {
                            Text(CupcakeCornerFeature.types[$0])
                        }
                    }
                    
                    Stepper("Number of cakes: \(store.quantity)", value: $store.quantity, in: 3...20)
                }
                
                Section {
                    Toggle("Any special requests?", isOn: $store.specialRequestEnabled)
                    if store.specialRequestEnabled {
                        Toggle("Add extra frosting?", isOn: $store.extraFrosting)
                        
                        Toggle("Add extra sprinkles?", isOn: $store.addSprinkles)
                    }
                }
                
                Section {
                    Button("Deliver details") {
                        store.send(.deliveryDetailsButtonTapped)
                    }
                }
            }
            .navigationTitle("Cupcake Corner")
        } destination: { store in
            switch store.case {
            case .address(let childStore):
                AddressView(store: childStore)
            case .checkout(let childStore):
                CheckoutView(store: childStore)
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
