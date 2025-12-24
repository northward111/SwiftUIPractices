//
//  UserList.swift
//  FriendFaceTCA
//
//  Created by hn on 2025/11/27.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct UserList {
    @ObservableState
    struct State: Equatable {
        var users: IdentifiedArrayOf<User> = []
    }
    
    enum Action {
        case onAppear
        case usersLoaded([User])
        case userTapped(User)
        case delegate(Delegate)
        
        enum Delegate {
            case gotoUserDetail(User)
        }
    }
    
    @Dependency(\.databaseService) var databaseService
    @Dependency(\.apiClient) var apiClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let usersFromDB = try databaseService.fetchUsers()
                    if usersFromDB.isEmpty {
                        let usersFromAPI = try await apiClient.fetchUsers()
                        try databaseService.saveUsers(usersFromAPI)
                        await send(.usersLoaded(usersFromAPI))
                    }else {
                        await send(.usersLoaded(usersFromDB))
                    }
                }
            case .usersLoaded(let users):
                state.users = IdentifiedArray(uniqueElements: users)
                return .none
            case .userTapped(let user):
                return .send(.delegate(.gotoUserDetail(user)))
            case .delegate:
                return .none
            }
        }
    }
}

struct UserListView: View {
    let store: StoreOf<UserList>
    var body: some View {
        Group {
            if store.users.isEmpty {
                ContentUnavailableView("No users yet", systemImage: "eraser")
            } else {
                List(store.users) { user in
                    Button {
                        store.send(.userTapped(user))
                    } label: {
                        UserCell(user: user)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("FriendFace")
        .onAppear {
            store.send(.onAppear)
        }
    }
}

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

#Preview {
    NavigationStack {
        UserListView(store: Store(initialState: UserList.State(), reducer: {
            UserList()
        }))
    }
}

