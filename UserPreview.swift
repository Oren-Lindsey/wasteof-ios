//
//  UserPreview.swift
//  wasteof.money
//
//  Created by Oren Lindsey on 10/26/23.
//

import SwiftUI

struct UserPreview: View {
    @Environment(\.displayScale) var displayScale
    let name: String
    let id: String
    let bio: String
    let verified: Bool
    let beta: Bool
    let permissions: Permissions
    let links: [Link]
    let history: History
    let stats: ExploreStats
    let color: String
    var profileColor: Color {
        switch color {
        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "green":
            return Color.green
        case "teal":
            return Color.teal
        case "blue":
            return Color.blue
        case "indigo":
            return Color.indigo
        case "violet":
            return Color.purple
        case "fuchsia":
            return Color.pink
        case "pink":
            return Color.pink
        case "gray":
            return Color.gray
        case "rainbow":
            return Color.gray
        default:
            return Color.green
        }
    }
    var body: some View {
        let jointime: Date = Date(timeIntervalSince1970: TimeInterval(history.joined / 1000))
        HStack {
            AsyncImage(
                url: URL(string: "https://api.wasteof.money/users/\(name)/picture"),
                transaction: Transaction(animation: .easeInOut)
            ) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .transition(.scale(scale: 0.1, anchor: .center))
                case .failure:
                    Image(systemName: "wifi.slash")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 60)
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(self.profileColor, lineWidth: 4)
            )
            Text("@\(name)")
                .font(.title2)
            if verified {
                Image(systemName: "checkmark.seal.fill")
            }
            if permissions.admin {
                Image(systemName: "checkmark.shield.fill")
            }
            if beta {
                Image(systemName: "testtube.2")
            }
            if bio.count > 0 {
                Text(bio).font(.callout).padding(1)
            }
            Spacer()
            VStack {
                Text("Joined \(jointime.formatted(date: .numeric, time: .omitted))")
                //.font(Font.body.italic())
                    .font(.footnote)
                Text("\(stats.followers) followers")
                    .font(.footnote)
            }
        }.padding().background(
            AsyncImage(url: URL(string:"https://api.wasteof.money/users/\(name)/banner")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .transition(.scale(scale: 0.1, anchor: .center))
                        .scaledToFill()
                        .clipped()
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .opacity(0.4)
                case .failure:
                    Image(systemName: "wifi.slash")
                @unknown default:
                    EmptyView()
                }
            }
        ).frame(maxHeight: 100).background(.regularMaterial,in:RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    UserPreview(name: "oren", id: "123", bio: "Hello World", verified: true, beta: true, permissions: Permissions(admin:true, banned: true), links: [],  history: History(joined: 1626708880151), stats: ExploreStats(followers: 198), color: "orange")
}
