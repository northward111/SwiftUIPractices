//
//  CounterFeature.swift
//  TCAField1
//
//  Created by hn on 2025/11/8.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CounterFeature {
    @ObservableState
    struct State: Equatable {
        var count = 0
        var isLoading = false
        var fact: String?
        var isTimerRunning = false
    }
    
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case toggleTimerButtonTapped
        case timerTick
    }
    
    enum CancelID { case timer }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.numberFact) var  numberFact
    
    var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                return .none
            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none
            case .factButtonTapped:
                state.isLoading = true
                state.fact = nil
                return .run { [count = state.count] send in
                    try await send(.factResponse(self.numberFact.fetch(count)))
                }
            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                }else {
                    return .cancel(id: CancelID.timer)
                }
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
            }
        }
    }
    
}

struct CounterView: View {
    let store: StoreOf<CounterFeature>
    var body: some View {
        VStack {
            Text("\(store.count)")
                .font(.largeTitle)
                .padding()
                .background(.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            HStack {
                Button("-") {
                    store.send(.decrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Button(store.isTimerRunning ? "Stop timer" : "Start timer") {
                store.send(.toggleTimerButtonTapped)
            }
            .font(.largeTitle)
            .padding()
            .background(.black.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Button("Fact") {
                store.send(.factButtonTapped)
            }
            .font(.largeTitle)
            .padding()
            .background(.black.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if store.isLoading {
                ProgressView()
            }else if let fact = store.fact {
                Text(fact)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

#Preview {
    CounterView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()
        }
    )
}
