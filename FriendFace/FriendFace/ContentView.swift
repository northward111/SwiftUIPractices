//
//  ContentView.swift
//  FriendFace
//
//  Created by hn on 2025/10/28.
//

import SwiftData
import SwiftUI

struct UserCell: View {
    let user: User
    var body: some View {
        VStack(alignment: .leading) {
            Text(user.name)
                .font(.title)
            Text(user.company)
                .font(.title2)
            Text("\(user.age) years old")
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var users: [User]
    @State private var userViewModel = UserViewModel(users: [])
    
    var body: some View {
        UserList(userViewModel: userViewModel)
            .onChange(of: users) { oldValue, newValue in
                userViewModel.users = newValue
            }
            .task {
                userViewModel.users = users
                await userViewModel.load(modelContext: modelContext)
            }
    }
    
}

struct UserList: View {
    @Bindable var userViewModel: UserViewModel
    var body: some View {
        NavigationStack {
            Group {
                if userViewModel.users.isEmpty {
                    ProgressView()
                } else {
                    List(userViewModel.users) { user in
                        NavigationLink(value: user) {
                            UserCell(user: user)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationDestination(for: User.self, destination: { user in
                        UserDetailView(user: user)
                    })
                }
            }
            .navigationTitle("FriendFace")
        }
    }
}

#Preview {
    ContentView()
}
