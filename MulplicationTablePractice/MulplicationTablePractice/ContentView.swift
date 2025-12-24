//
//  ContentView.swift
//  MulplicationTablePractice
//
//  Created by hn on 2025/8/20.
//

import SwiftUI

struct Question: Equatable, Identifiable {
    let id = UUID()
    let a: Int
    let b: Int
    var answer: Int?
    var correctAnswer: Int { a*b }
}

struct ContentView: View {
    static let questionNumberOptions = [5,10,20]
    @State private var tableMaxNumber = 9
    @State private var questionNumber = questionNumberOptions[0]
    @State private var questions: [Question] = []
    @State private var answers: [Int] = []
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
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
                    Stepper("Table up to: \(tableMaxNumber)", value: $tableMaxNumber)
                    Picker("Practice question number:", selection: $questionNumber) {
                        ForEach(ContentView.questionNumberOptions, id: \.self) { option in
                            Text("\(option)")
                        }
                    }
                }
                
                Section {
                    Button("Generate questions") {
                        refreshQuestions()
                    }
                }
                
                Section("Questions") {
                    ForEach($questions) { $question in
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
                        submit()
                    }
                }
            }
            .alert("Result", isPresented: $showingAlert, actions: {
                Button("Restart") {
                    refreshQuestions()
                }
            }, message: {
                Text("\(alertMessage)")
            })
            .onChange(of: tableMaxNumber, refreshQuestions)
            .onChange(of: questionNumber, refreshQuestions)
            .onAppear(perform: refreshQuestions)
        }
        
    }
    func refreshQuestions() {
        questions = []
        withAnimation(.default) {
            for _ in 0..<questionNumber {
                let a = Int.random(in: 1...tableMaxNumber)
                let b = Int.random(in: 1...tableMaxNumber)
                questions.append(Question(a: a, b: b))
            }
        }
    }
    func submit() {
        var score = 0
        for question in questions {
            if question.correctAnswer == question.answer {
                score += 1
            }
        }
        alertMessage = "\(score) questions correct."
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
