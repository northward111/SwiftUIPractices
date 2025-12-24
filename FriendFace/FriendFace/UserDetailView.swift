//
//  UserDetailView.swift
//  FriendFace
//
//  Created by hn on 2025/10/28.
//

import SwiftUI

struct UserDetailView: View {
    let user: User
    var body: some View {
        ScrollView {
            VStack {
                Text(user.name)
                    .font(.title)
                Text(user.about)
                    .font(.headline)
                Divider()
                Text("Friends:")
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(user.friends) { friend in
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
    UserDetailView(user: .sample())
}
