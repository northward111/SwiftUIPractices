//
//  AppFeature.swift
//  FriendFaceTCA
//
//  Created by hn on 2025/11/27.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @Reducer
    enum Path {
        case detail(UserDetail)
    }
    @ObservableState
    struct State: Equatable {
        var userList = UserList.State()
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case userList(UserList.Action)
        case path(StackActionOf<Path>)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.userList, action: \.userList) {
            UserList()
        }
        Reduce { state, action in
            switch action {
            case .path:
                return .none
            case .userList(.delegate(.gotoUserDetail(let user))):
                state.path.append(.detail(UserDetail.State(user: user)))
                return .none
            case .userList:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension AppFeature.Path.State: Equatable {}

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            UserListView(store: store.scope(state: \.userList, action: \.userList))
        } destination: { store in
            switch store.case {
            case .detail(let detailStore):
                UserDetailView(store: detailStore)
            }
        }
    }
}
