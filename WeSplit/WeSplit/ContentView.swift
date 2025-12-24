//
//  ContentView.swift
//  WeSplit
//
//  Created by hn on 2025/7/19.
//

import SwiftUI

struct ContentView: View {
    @State private var checkAmount = 0.0
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 20
    @FocusState private var amountIsFocused
    let tipPercentages = 0...100
    var grandTotal: Double {
        let tipSelection = Double(tipPercentage)
        let grandTotal = checkAmount * (1 + tipSelection/100)
        return grandTotal
    }
    var totalPerPerson: Double{
        let peopleCount = Double(numberOfPeople+2)
        let amountPerPerson = grandTotal / peopleCount
        return amountPerPerson
    }
    let currencyCode = Locale.current.currency?.identifier ?? "USD"
    var body: some View{
        NavigationStack{
            Form {
                Section {
                    TextField("Amount", value: $checkAmount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                        .focused($amountIsFocused)
                    Picker("Number of people", selection: $numberOfPeople) {
                        ForEach(2..<100, content: {
                            Text("\($0) people")
                        })
                    }
                    .pickerStyle(.navigationLink)
                }
                Section("How much tip do you want to leave?") {
                    Picker("Tip percentage", selection: $tipPercentage) {
                        ForEach(tipPercentages, id: \.self) {
                            Text($0, format: .percent)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                Section("Total amount with tip") {
                    Text(grandTotal, format: .currency(code: currencyCode))
                        .foregroundStyle(tipPercentage==0 ? .red : .black)
                }
                Section("Amount per person") {
                    Text(totalPerPerson, format: .currency(code: currencyCode))
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

#Preview {
    ContentView()
}
