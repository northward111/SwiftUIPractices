//
//  WeSplitFeature.swift
//  WeSplit
//
//  Created by hn on 2025/11/13.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct WeSplitFeature {
    @ObservableState
    struct State: Equatable {
        var checkAmount = 0.0
        var numberOfPeople = 2
        var tipPercentage = 20
        var grandTotal: Double {
            let tipSelection = Double(tipPercentage)
            let grandTotal = checkAmount * (1 + tipSelection/100)
            return grandTotal
        }
        var totalPerPerson: Double{
            let peopleCount = Double(numberOfPeople)
            let amountPerPerson = grandTotal / peopleCount
            return amountPerPerson
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}


struct WeSplitView: View {
    let currencyCode = Locale.current.currency?.identifier ?? "USD"
    let tipPercentages = 0...100
    @Bindable var store: StoreOf<WeSplitFeature>
    @FocusState private var amountIsFocused
    var body: some View {
        NavigationStack{
            Form {
                Section {
                    TextField("Amount", value: $store.checkAmount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                        .focused($amountIsFocused)
                    Picker("Number of people", selection: $store.numberOfPeople) {
                        ForEach(2..<100, content: {
                            Text("\($0) people")
                                .tag($0)
                        })
                    }
                    .pickerStyle(.navigationLink)
                }
                Section("How much tip do you want to leave?") {
                    Picker("Tip percentage", selection: $store.tipPercentage) {
                        ForEach(tipPercentages, id: \.self) {
                            Text($0, format: .percent)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                Section("Total amount with tip") {
                    Text(store.grandTotal, format: .currency(code: currencyCode))
                        .foregroundStyle(store.tipPercentage == 0 ? .red : .black)
                }
                Section("Amount per person") {
                    Text(store.totalPerPerson, format: .currency(code: currencyCode))
                }
            }
            .navigationTitle("WeSplit")
            .toolbar {
                if amountIsFocused {
                    Button("Done") {
                        amountIsFocused = false
                    }
                }
            }
        }
    }
}
