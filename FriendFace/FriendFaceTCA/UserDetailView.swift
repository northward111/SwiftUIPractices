//
//  UserDetailView.swift
//  FriendFace
//
//  Created by hn on 2025/10/28.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct UserDetail {
    @ObservableState
    struct State: Equatable {
        let user: User
    }
}


struct UserDetailView: View {
    let store: StoreOf<UserDetail>
    var body: some View {
        ScrollView {
            VStack {
                Text(store.user.name)
                    .font(.title)
                Text(store.user.about)
                    .font(.headline)
                Divider()
                Text("Friends:")
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(store.user.friends) { friend in
                            Text(friend.name)
                                .padding(5)
                                .clipShape(.capsule)
                                .background {
                                    Color.blue
                                }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    UserDetailView(store: Store(initialState: UserDetail.State(user: .sample()), reducer: {
        UserDetail()
    }))
}
