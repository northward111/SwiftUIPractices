//
//  ContentView.swift
//  WordScramble
//
//  Created by hn on 2025/8/2.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Score: \(score)")
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        .accessibilityElement()
                        .accessibilityLabel(word)
                        .accessibilityHint("\(word.count) letters")
                    }
                }
            }
            .toolbar(content: {
                Button("Restart", action: startGame)
            })
            .navigationTitle(rootWord)
        }
        .onSubmit(addNewWord)
        .onAppear(perform: startGame)
        .alert(alertTitle, isPresented: $showingAlert) {} message: {
            Text(alertMessage)
        }
    }
    
    func addNewWord() -> Void {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {
            return
        }
        guard isNotTooShort(word: answer) else {
            wordError(title: "Word is too short", message: "It must contain more than three letters")
            return
        }
        guard isNotJustStartWord(word: answer) else {
            wordError(title: "Word is the same as root word", message: "It must be different from the root word")
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can not spell that word from \(rootWord)")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You cannot just make them up, you know!")
            return
        }
        score += newWord.count
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() -> Void {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = []
                newWord = ""
                score = 0
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    func isNotTooShort(word: String) -> Bool {
        return word.count >= 3
    }
    func isNotJustStartWord(word: String) -> Bool {
        return word != rootWord
    }
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for char in word {
            if let pos = tempWord.firstIndex(of: char) {
                tempWord.remove(at: pos)
            }else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) -> Void {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
