//
//  ContentView.swift
//  BetterRest
//
//  Created by hn on 2025/7/31.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var showedBedtime = ""
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    func refreshShowedBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let bedTime = wakeUp - prediction.actualSleep
            showedBedtime = bedTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            print("Prediction failed: \(error.localizedDescription)")
            showedBedtime = "Calculation error"
        }
    }
    
    var body: some View {
        NavigationStack{
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                }
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section("Daily coffee intake") {
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(1..<21) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                }
                Section("You'd better go to bed at") {
                    Text(showedBedtime)
                }
                
            }
            .navigationTitle("BetterRest")
        }
        .onAppear(perform: refreshShowedBedtime)
        .onChange(of: sleepAmount, refreshShowedBedtime)
        .onChange(of: wakeUp, refreshShowedBedtime)
        .onChange(of: coffeeAmount, refreshShowedBedtime)
        
    }
    
}

#Preview {
    ContentView()
}
