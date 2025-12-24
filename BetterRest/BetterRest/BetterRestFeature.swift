//
//  BetterRestFeature.swift
//  BetterRest
//
//  Created by hn on 2025/11/14.
//

import ComposableArchitecture
import CoreML
import SwiftUI

struct SleepCalculatorClient {
    var predict: @Sendable (_ wake: Double, _ sleep: Double, _ coffee: Double) async throws -> Double
}

private enum SleepCalculatorClientKey: DependencyKey {
    static var liveValue: SleepCalculatorClient {
        let config = MLModelConfiguration()
        let model = try! SleepCalculator(configuration: config)
        return SleepCalculatorClient { wake, sleep, coffee in
            let result = try model.prediction(
                wake: wake,
                estimatedSleep: sleep,
                coffee: coffee
            )
            return result.actualSleep
        }
    }
}

extension DependencyValues {
    var sleepCalculatorClient: SleepCalculatorClient {
        get {
            self[SleepCalculatorClientKey.self]
        }
        set {
            self[SleepCalculatorClientKey.self] = newValue
        }
    }
}

@Reducer
struct BetterRestFeature {
    @ObservableState
    struct State: Equatable {
        var sleepAmount = 8.0
        var wakeUp = defaultWakeTime
        var coffeeAmount = 1
        var showedBedtime = ""
        static var defaultWakeTime: Date {
            var components = DateComponents()
            components.hour = 7
            components.minute = 0
            return Calendar.current.date(from: components) ?? .now
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case appear
        case predictionResponse(Result<TimeInterval, Error>)
    }
    
    @Dependency(\.sleepCalculatorClient) var sleepCalculatorClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            let predictionEffect = Effect.run { [state] send in
                do {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: state.wakeUp)
                    let hour = (components.hour ?? 0) * 60 * 60
                    let minute = (components.minute ?? 0) * 60
                    let prediction = try await sleepCalculatorClient.predict(Double(hour + minute), state.sleepAmount, Double(state.coffeeAmount))
                    await send(Action.predictionResponse(.success(prediction)))
                } catch {
                    await send(Action.predictionResponse(.failure(error)))
                }
            }
            switch action {
            case let .binding(bindingAction):
                let keyPath = bindingAction.keyPath
                switch keyPath {
                case \.coffeeAmount, \.sleepAmount, \.wakeUp:
                    return predictionEffect
                default:
                    break
                }
                return .none
            case .appear:
                return predictionEffect
            case let .predictionResponse(.success(interval)):
                let bedTime = state.wakeUp - interval
                state.showedBedtime = bedTime.formatted(date: .omitted, time: .shortened)
                return .none
            case .predictionResponse(.failure):
                state.showedBedtime = "Calculation error"
                return .none
            }
        }
    }
    
}

struct BetterRestView: View {
    @Bindable var store: StoreOf<BetterRestFeature>
    var body: some View {
        NavigationStack{
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $store.wakeUp, displayedComponents: .hourAndMinute)
                }
                Section("Desired amount of sleep") {
                    Stepper("\(store.sleepAmount.formatted()) hours", value: $store.sleepAmount, in: 4...12, step: 0.25)
                }
                Section("Daily coffee intake") {
                    Picker("^[\(store.coffeeAmount) cup](inflect: true)", selection: $store.coffeeAmount) {
                        ForEach(1..<21) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                }
                Section("You'd better go to bed at") {
                    Text(store.showedBedtime)
                }
            }
            .navigationTitle("BetterRest")
        }
        .onAppear {
            store.send(.appear)
        }
    }
}
