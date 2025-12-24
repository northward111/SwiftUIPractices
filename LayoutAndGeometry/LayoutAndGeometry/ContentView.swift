//
//  ContentView.swift
//  LayoutAndGeometry
//
//  Created by hn on 2025/11/5.
//

import SwiftUI

struct ContentView: View {
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    @State private var resultStore = ResultStore()
    @State private var isActive = false
    @State private var lastDice: Int?
    @State private var remainingTickCount = 3
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Picker(selection: $resultStore.diceOption) {
                    ForEach(ResultStore.diceOptions, id: \.self) {
                        Text("\($0) sided")
                    }
                } label: {
                    Text("\(resultStore.diceOption)")
                }
                HStack {
                    Button(action: roll) {
                        Image(systemName: "dice")
                            .font(.largeTitle)
                    }
                    .disabled(isActive)
                    Text("\(lastDice ?? 0)")
                }
                
                Text("Total: \(resultStore.totalRolled)")
                List(0..<resultStore.results.count, id: \.self) { index in
                    let result = resultStore.results[index]
                    Text("\(result)")
                }
            }
            .navigationTitle("DiceRoller")
            .toolbar {
                Button("Restart", action: restart)
            }
            .onReceive(timer, perform: tick)
            .animation(.default, value: lastDice)
        }
    }
    
    func roll() {
        isActive = true
        remainingTickCount = 3
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func restart() {
        resultStore.results = []
    }
    
    func tick(date: Date) {
        guard isActive else {
            return
        }
        let randomDice = Int.random(in: 1...resultStore.diceOption, exclude: lastDice)
        lastDice = randomDice
        if remainingTickCount > 1 {
            remainingTickCount -= 1
        }else {
            resultStore.results.append(randomDice)
            isActive = false
        }
    }
}

#Preview {
    ContentView()
}
