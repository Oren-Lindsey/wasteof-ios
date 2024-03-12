//
//  Settings.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 3/12/24.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var session: Session
    var body: some View {
        ScrollView {
            VStack {
                Button {
                    session.token = ""
                    session.name = ""
                    session.color = "indigo"
                    session.bio = ""
                    session.verified = false
                    session.permissions = Permissions(admin: false, banned: false)
                    session.beta = false
                    session.color = ""
                    session.links = []
                    session.history = History(joined: 0)
                    session.stats = UserStats(followers: 0, following: 0, posts: 0)
                    session.online = false
                    session.token = ""
                } label: {
                    Label("Log Out", systemImage: "trash")
                }
            }
        }.navigationTitle("Settings")
    }
}

#Preview {
    Settings()
}
