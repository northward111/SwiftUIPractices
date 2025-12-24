//
//  AstronautView.swift
//  Moonshot
//
//  Created by hn on 2025/10/15.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AstronautFeature {
    @ObservableState
    struct State: Equatable {
        let astronaut: Astronaut
    }
}

struct AstronautView: View {
    let store: StoreOf<AstronautFeature>
    var body: some View {
        ScrollView {
            VStack {
                Image(store.astronaut.id)
                    .resizable()
                    .scaledToFit()
                    .accessibilityHidden(true)
                
                Text(store.astronaut.description)
                    .padding()
            }
        }
        .background(.darkBackground)
    }
}

#Preview {
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")
    return AstronautView(store: Store(initialState: AstronautFeature.State(astronaut: astronauts["aldrin"]!), reducer: {
        AstronautFeature()
    }))
        .preferredColorScheme(.dark)
}
