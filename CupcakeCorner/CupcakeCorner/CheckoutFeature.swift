//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by hn on 2025/10/23.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CheckoutFeature {
    @ObservableState
    struct State: Equatable {
        let cost: Decimal
        let order: Order
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case placeOrderButtonTapped
        case alert(PresentationAction<Alert>)
        case orderResponse(Result<Order, OrderError>)
        
        enum Alert: Equatable {
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .placeOrderButtonTapped:
                return .run { [order = state.order] send in
                    let result = await placeOrder(order: order)
                    await send(.orderResponse(result))
                }
            case .orderResponse(let result):
                state.alert = .fromOrderResult(result)
            case .alert:
                break
            }
            return .none
        }
        .ifLet(\.alert, action: \.alert)
    }
    
    
    
    func placeOrder(order: Order) async -> Result<Order, OrderError> {
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return .failure(.encodeError)
        }
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("reqres-free-v1", forHTTPHeaderField: "x-api-key")
        request.httpMethod = "POST"
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print(String(data: data, encoding: .utf8) ?? "No data")
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            return .success(decodedOrder)
        } catch {
            print("Checkout failed \(error.localizedDescription)")
            return .failure(.networkError(error.localizedDescription))
        }
    }
}

enum OrderError: Error {
    case encodeError
    case networkError(String)
}

extension AlertState {
    static func fromOrderResult(_ result: Result<Order, OrderError>) -> AlertState {
        switch result {
        case .success(let order):
            return AlertState {
                TextState("Thank you!")
            } actions: {
                ButtonState {
                    TextState("OK")
                }
            } message: {
                TextState(
                    "Your order for \(order.quantity)x \(CupcakeCornerFeature.types[order.type].lowercased()) cupcakes is on its way!"
                )
            }
        case .failure(let error):
            switch error {
            case .encodeError:
                return AlertState {
                    TextState("Encode error")
                } actions: {
                    ButtonState {
                        TextState("OK")
                    }
                } message: {
                    TextState(
                        "Encode order data failed."
                    )
                }
            case .networkError(let description):
                return AlertState {
                    TextState("Network error")
                } actions: {
                    ButtonState {
                        TextState("OK")
                    }
                } message: {
                    TextState(description)
                }
            }
        }
    }
}


struct CheckoutView: View {
    @Bindable var store: StoreOf<CheckoutFeature>
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                .accessibilityHidden(true)
                
                Text("Your total is \(store.cost, format: .currency(code: "USD"))")
                    .font(.title)
                Button("Place Order") {
                    store.send(.placeOrderButtonTapped)
                }
                .padding()
            }
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
        .scrollBounceBehavior(.basedOnSize)
        .alert(store: store.scope(state: \.$alert, action: \.alert))
    }
}

//#Preview {
//    CheckoutView(order: Order())
//}
