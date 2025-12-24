//
//  ContentView.swift
//  Moonshot
//
//  Created by hn on 2025/10/11.
//

import SwiftUI

let columns = [
    GridItem(.adaptive(minimum: 150))
]

let listColumns = [
    GridItem(.flexible())
]

let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")
let missions: [Mission] = Bundle.main.decode("missions.json")

//struct MissionCell: View {
//    let mission: Mission
//    var body: some View {
//        VStack {
//            Image(mission.image)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 100, height: 100)
//                .padding()
//            VStack {
//                Text(mission.displayName)
//                    .font(.headline)
//                    .foregroundStyle(.white)
//                Text(mission.formattedLaunchDate)
//                    .font(.caption)
//                    .foregroundStyle(.white.opacity(0.5))
//                    .accessibilityLabel(mission.formattedLaunchDateLabel)
//            }
//            .padding(.vertical)
//            .frame(maxWidth: .infinity)
//            .background(.lightBackground)
//        }
//        .clipShape(.rect(cornerRadius: 10))
//        .overlay {
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(.lightBackground)
//        }
//    }
//}

//struct ContentView: View {
//    @State private var isList = false
//    struct GridLayout: View {
//        let missions: [Mission]
//        let astronauts: [String: Astronaut]
//        var body: some View {
//            ScrollView {
//                LazyVGrid(columns: columns) {
//                    ForEach(missions) { mission in
//                        NavigationLink(value: mission) {
//                            MissionCell(mission: mission)
//                        }
//                    }
//                }
//                .padding([.horizontal, .bottom])
//            }
//        }
//    }
//    struct ListLayout: View {
//        let missions: [Mission]
//        let astronauts: [String: Astronaut]
//        var body: some View {
//            List(missions) { mission in
//                NavigationLink(value: mission) {
//                    MissionCell(mission: mission)
//                }
//                .listRowBackground(Color.darkBackground)
//            }
//            .listStyle(.plain)
//        }
//    }
//    var body: some View {
//        NavigationStack {
//            Group {
//                if isList {
//                    ListLayout(missions: missions, astronauts: astronauts)
//                }else {
//                    GridLayout(missions: missions, astronauts: astronauts)
//                }
//            }
//            .navigationTitle("Moonshot")
//            .navigationDestination(for: Mission.self, destination: { mission in
//                MissionDetailView(mission: mission, astronauts: astronauts)
//            })
//            .background(.darkBackground)
//            .preferredColorScheme(.dark)
//            .toolbar {
//                Button("Grid|List") {
//                    withAnimation {
//                        isList.toggle()
//                    }
//                }
//                .accessibilityLabel("Grid or List")
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
