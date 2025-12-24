//
//  MultiplicationTablePracticeFeature.swift
//  MulplicationTablePractice
//
//  Created by hn on 2025/11/17.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MultiplicationTablePracticeFeature {
    static let questionNumberOptions = [5,10,20]
    @ObservableState
    struct State: Equatable {
        var tableMaxNumber = 9
        var questionNumber = questionNumberOptions[0]
        var questions: [Question] = []
        var answers: [Int] = []
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case generateQuestionsButtonTapped
        case submitButtonTapped
        case onAppear
        enum Alert {
            case restart
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(let bindingAction):
                switch bindingAction.keyPath {
                case \.tableMaxNumber, \.questionNumber:
                    refreshQuestions(state: &state)
                default:
                    break
                }
            case .alert(.presented(.restart)):
                refreshQuestions(state: &state)
            case .alert:
                break
            case .generateQuestionsButtonTapped, .onAppear:
                refreshQuestions(state: &state)
            case .submitButtonTapped:
                submit(state: &state)
            }
            return .none
        }
        .ifLet(\.alert, action: \.alert)
    }
    
    func refreshQuestions(state: inout State) {
        state.questions = []
        state.questions = (0..<state.questionNumber).map { _ in
            let a = Int.random(in: 1...state.tableMaxNumber)
            let b = Int.random(in: 1...state.tableMaxNumber)
            return Question(a: a, b: b)
        }
    }
    func submit(state: inout State) {
        var score = 0
        for question in state.questions {
            if question.correctAnswer == question.answer {
                score += 1
            }
        }
        state.alert = AlertState {
            TextState("Result")
        } actions: {
            ButtonState(action: .restart) {
                TextState("Restart")
            }
        } message: {
            TextState("\(score) questions correct.")
        }
    }
}

struct MultiplicationTablePracticeView: View {
    @Bindable var store: StoreOf<MultiplicationTablePracticeFeature>
    @FocusState private var focusedField: UUID?
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            Form {
                Section("Settings") {
                    Stepper("Table up to: \(store.tableMaxNumber)", value: $store.tableMaxNumber)
                    Picker("Practice question number:", selection: $store.questionNumber) {
                        ForEach(MultiplicationTablePracticeFeature.questionNumberOptions, id: \.self) { option in
                            Text("\(option)")
                        }
                    }
                }
                
                Section {
                    Button("Generate questions") {
                        withAnimation {
                            _ = store.send(.generateQuestionsButtonTapped)
                        }
                    }
                }
                
                Section("Questions") {
                    ForEach($store.questions) { $question in
                        HStack{
                            Text("\(question.a) X \(question.b) = ")
                            Spacer()
                            TextField("", text: Binding(get: {
                                question.answer.map(String.init) ?? ""
                            }, set: {
                                question.answer = Int($0)
                            }))
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: question.id)
                        }
                    }
                }
                Section {
                    Button("Submit") {
                        store.send(.submitButtonTapped)
                    }
                }
            }
            .onAppear(perform: {
                store.send(.onAppear)
            })
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}
