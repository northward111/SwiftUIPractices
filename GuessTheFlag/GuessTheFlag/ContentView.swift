//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by hn on 2025/7/22.
//

import SwiftUI

struct FlagImage: View {
    var countryName: String
    var body: some View {
        Image(countryName)
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}

struct ContentView: View {
    let labels = [
        "Estonia": "Flag with three horizontal stripes. Top stripe blue, middle stripe black, bottom stripe white.",
        "France": "Flag with three vertical stripes. Left stripe blue, middle stripe white, right stripe red.",
        "Germany": "Flag with three horizontal stripes. Top stripe black, middle stripe red, bottom stripe gold.",
        "Ireland": "Flag with three vertical stripes. Left stripe green, middle stripe white, right stripe orange.",
        "Italy": "Flag with three vertical stripes. Left stripe green, middle stripe white, right stripe red.",
        "Nigeria": "Flag with three vertical stripes. Left stripe green, middle stripe white, right stripe green.",
        "Poland": "Flag with two horizontal stripes. Top stripe white, bottom stripe red.",
        "Spain": "Flag with three horizontal stripes. Top thin stripe red, middle thick stripe gold with a crest on the left, bottom thin stripe red.",
        "UK": "Flag with overlapping red and white crosses, both straight and diagonally, on a blue background.",
        "Ukraine": "Flag with two horizontal stripes. Top stripe blue, bottom stripe yellow.",
        "US": "Flag with many red and white stripes, with white stars on a blue background in the top-left corner."
    ]
    @State private var showingScore = false
    @State private var showingRestart = false
    @State private var scoreTitle = ""
    @State private var scoreMessage = ""
    @State private var countries = ["Estonia", "UK", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Ukraine", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var score = 0
    @State private var answeredCount = 0
    private let maxAnswerCount = 8
    @State private var tappedNumber: Int?
    var body: some View {
        ZStack {
//            LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
//                .ignoresSafeArea()
            RadialGradient(stops: [.init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),.init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)], center: .top, startRadius: 200, endRadius: 400)
                .ignoresSafeArea()
            VStack{
                Spacer()
                Text("Guess the Flag")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                VStack(spacing: 15) {
                    VStack{
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(countryName: countries[number])
                                .rotation3DEffect(.degrees(tappedNumber == number ? 360 : 0), axis: (x:0, y:1, z:0))
                                .opacity(isUntappedFlag(num: number) ? 0.25 : 1.0)
                                .scaleEffect(isUntappedFlag(num: number) ? 0.5 : 1.0)
                        }
                        .accessibilityLabel(labels[countries[number], default:"Unknown flag"])
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                Spacer()
                Spacer()
                Text("Tries: \(answeredCount)/\(maxAnswerCount)")
                    .font(.title)
                    .foregroundStyle(.white)
                Text("Score: \(score)")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding()
            
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue") {
                askQuestion()
            }
        } message: {
            Text(scoreMessage)
        }
        .alert(scoreTitle, isPresented: $showingRestart) {
            Button("Restart") {
                restartGame()
            }
        } message: {
            Text(scoreMessage)
        }
    }
    func isUntappedFlag(num: Int) -> Bool {
        guard let tappedNumber = tappedNumber else { return false }
        return tappedNumber != num
    }
    func flagTapped(_ number: Int) -> Void {
        withAnimation {
            tappedNumber = number
        } completion: {
            if number == correctAnswer {
                scoreTitle = "Correct"
                score += 1
                scoreMessage = ""
            }else{
                scoreTitle = "Wrong"
                scoreMessage = "That's the flag of \(countries[number])\n"
                score -= 1
            }
            scoreMessage += "Your score is \(score)"
            answeredCount += 1
            if answeredCount == maxAnswerCount {
                showingRestart = true
            }else{
                showingScore = true
            }
        }
    }
    func askQuestion() -> Void {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        tappedNumber = nil
    }
    func restartGame() -> Void {
        answeredCount = 0
        score = 0
        askQuestion()
    }
}

#Preview {
    ContentView()
}
