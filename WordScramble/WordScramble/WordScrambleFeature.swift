//
//  WordScrambleFeature.swift
//  WordScramble
//
//  Created by hn on 2025/11/16.
//

import ComposableArchitecture
import SwiftUI

struct RandomClient {
    var _element: (_ array: [Any]) -> Any?
    func element<T>(_ array: [T]) -> T? {
        self._element(array) as? T
    }
}

private enum RandomClientDependencyKey: DependencyKey {
    static var liveValue: RandomClient = RandomClient { array in
        array.randomElement()
    }
}

extension DependencyValues {
    var randomClient: RandomClient {
        get {
            self[RandomClientDependencyKey.self]
        }
        set {
            self[RandomClientDependencyKey.self] = newValue
        }
    }
}

@Reducer
struct WordScrambleFeature {
    @ObservableState
    struct State: Equatable {
        var usedWords = [String]()
        var rootWord = ""
        var newWord = ""
        var score = 0
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case onAppear
        case restartButtonTapped
        case onSubmit
        enum Alert: Equatable {
        }
    }
    
    @Dependency(\.randomClient) var randomClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .alert:
                break
            case .binding:
                break
            case .onAppear:
                startGame(state: &state)
            case .restartButtonTapped:
                startGame(state: &state)
            case .onSubmit:
                addNewWord(state: &state)
            }
            return .none
        }
        .ifLet(\.alert, action: \.alert)
    }
    
    func startGame(state: inout State) {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: "\n")
                state.rootWord = randomClient.element(allWords) ?? "silkworm"
                state.usedWords = []
                state.newWord = ""
                state.score = 0
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func addNewWord(state: inout State) {
        let answer = state.newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {
            return
        }
        guard isNotTooShort(word: answer) else {
            wordError(state: &state, title: "Word is too short", message: "It must contain more than three letters")
            return
        }
        guard isNotJustStartWord(word: answer, rootWord: state.rootWord) else {
            wordError(state: &state, title: "Word is the same as root word", message: "It must be different from the root word")
            return
        }
        guard isOriginal(word: answer, usedWords: state.usedWords) else {
            wordError(state: &state, title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer, rootWord: state.rootWord) else {
            wordError(state: &state, title: "Word not possible", message: "You can not spell that word from \(state.rootWord)")
            return
        }
        guard isReal(word: answer) else {
            wordError(state: &state, title: "Word not recognized", message: "You cannot just make them up, you know!")
            return
        }
        state.score += state.newWord.count
        state.usedWords.insert(answer, at: 0)
        state.newWord = ""
    }
    
    func isNotTooShort(word: String) -> Bool {
        return word.count >= 3
    }
    func isNotJustStartWord(word: String, rootWord: String) -> Bool {
        return word != rootWord
    }
    func isOriginal(word: String, usedWords: [String]) -> Bool {
        return !usedWords.contains(word)
    }
    func isPossible(word: String, rootWord: String) -> Bool {
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
    func wordError(state: inout State, title: String, message: String) {
        state.alert = AlertState {
            TextState(title)
        } message: {
            TextState(message)
        }
    }
}

struct WordScrambleView: View {
    @Bindable var store: StoreOf<WordScrambleFeature>
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Score: \(store.score)")
                    TextField("Enter your word", text: $store.newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(store.usedWords, id: \.self) { word in
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
                Button("Restart") {
                    store.send(.restartButtonTapped)
                }
            })
            .navigationTitle(store.rootWord)
        }
        .onSubmit {
            withAnimation {
                _ = store.send(.onSubmit)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert(store: store.scope(state: \.$alert, action: \.alert))
    }
}
