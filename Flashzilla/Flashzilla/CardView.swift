//
//  CardView.swift
//  Flashzilla
//
//  Created by hn on 2025/11/4.
//

import SwiftUI

extension Shape {
    func fill<S>(by value: Double, less: S, equals: S, greater: S) -> some View where S: ShapeStyle{
        if value < 0 {
            return self.fill(less)
        }else if value == 0 {
            return self.fill(equals)
        }else {
            return self.fill(greater)
        }
    }
}

struct CardView: View {
    @Environment(
        \.accessibilityDifferentiateWithoutColor
    ) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    let card: Card
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    var removal: ((Bool) -> Void)?
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    accessibilityDifferentiateWithoutColor ?
                        .white : .white
                        .opacity(1 - Double(abs(offset.width / 50)))
                )
                .background(
                    accessibilityDifferentiateWithoutColor ?
                    nil :
                        RoundedRectangle(cornerRadius: 25)
                        .fill(by: offset.width, less: .red, equals: .white, greater: .green)
                )
                .shadow(radius: 10)
            
            VStack {
                if accessibilityVoiceOverEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                }else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(offset.width / 5.0))
        .offset(x: offset.width * 5)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibilityAddTraits(.isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded{ _ in
                    if abs(offset.width) > 100 {
                        let isRight = offset.width > 0
                        removal?(isRight)
                        if isRight == false {
                            offset = .zero
                        }
                    }else {
                        offset = .zero
                    }
                    print("Offset: \(offset)")
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
        .animation(.bouncy, value: offset)
    }
}

#Preview {
    CardView(card: .example)
}
