//
//  About.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 3/14/24.
//

import SwiftUI

struct About: View {
    @State var showToken = false
    @EnvironmentObject var session: Session
    let appIcon: String
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 12) {
                if let image = UIImage(named: appIcon) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                VStack {
                    Text("wasteof.money for iOS")
                    Text("App version \(UIApplication.appVersion ?? "nil")").font(.footnote)
                }
            }.fixedSize()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("App version \(UIApplication.appVersion ?? "nil")")
            Text("wasteof.money was made by @jeffalo")
            Text("The iOS app was made by Oren Lindsey")
            Divider()
            Text("Token (don't share this!):")
            if showToken {
                Text(session.token).font(.system(.body, design: .monospaced)).textSelection(.enabled)
            } else {
                Button {
                    showToken.toggle()
                } label: {
                    Label("Show token", systemImage: "lock")
                }.buttonStyle(.bordered)
            }
            Spacer()
        }
    }
}
