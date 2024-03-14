//
//  Wall.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 1/8/24.
//

import SwiftUI

struct Wall: View {
    @EnvironmentObject var session: Session
    var username: String
    @StateObject var wallFeed: WallObject = WallObject()
    @State var checkedComments = false
    @State var page = 1
    var color: Color?
    var profileColor: Color {
        switch session.color {
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
        ScrollView {
            WallCommentButton(type: "comment", username: username, parent: nil, color: profileColor).onPost {
                page = 1
                checkedComments = false
            }
            if !checkedComments {
                ProgressView().onAppear() {
                    fetchWall(user: username, page: page) { (results) in
                        DispatchQueue.main.async {
                            wallFeed.comments = results.comments
                            wallFeed.last = results.last
                            checkedComments = true
                        }
                    }
                }
            } else {
                if wallFeed.comments.count > 0 {
                    ForEach(wallFeed.comments.indices, id: \.self) { i in
                        let comment = wallFeed.comments[i]
                        WallCommentPreview(id: comment._id, parent: comment.parent, content: comment.content, wall: comment.wall, poster: comment.poster, time: comment.time, hasReplies: comment.hasReplies, recursion: 1).padding([.vertical],2).environmentObject(session)
                    }
                    if !wallFeed.last {
                        Button {
                            page += 1
                            fetchWall(user: username, page: page) { (results) in
                                DispatchQueue.main.async {
                                    wallFeed.comments += results.comments
                                    wallFeed.last = results.last
                                    checkedComments = true
                                }
                            }
                        } label: {
                            Image(systemName: "text.bubble")
                            Text("Show more")
                        }.buttonStyle(.bordered).tint(color ?? profileColor)
                    }
                } else {
                    Text("No comments yet :(")
                }
            }
        }.navigationTitle("@\(username)'s Wall").refreshable {
            page = 1
            fetchWall(user: username, page: page) { (results) in
                DispatchQueue.main.async {
                    wallFeed.comments = results.comments
                    wallFeed.last = results.last
                    checkedComments = true
                }
            }
        }
    }
}
struct WallUser: Hashable, Codable {
    var name: String
    var id: String
}
struct WallComment: Hashable, Codable {
    var _id: String
    var parent: Optional<String>
    var content: String
    var wall: WallUser
    var poster: CommentPoster
    var time: Int
    var hasReplies: Bool
}
class WallObject: ObservableObject {
    @Published var comments: [WallComment]
    @Published var last: Bool
    init() {
            self.comments = []
            self.last = true
        }
}
class WallType: Hashable, Codable {
    static func == (lhs: WallType, rhs: WallType) -> Bool {
        return lhs.comments == rhs.comments && lhs.last == rhs.last
    }
    
    var comments: [WallComment]
    var last: Bool
    init() {
        self.comments = []
        self.last = true
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(comments)
        hasher.combine(last)
    }
}
func fetchWall(user: String, page: Int, callback: ((WallObject) -> ())? = nil) {
    guard let url = URL(string: "https://api.wasteof.money/users/\(user)/wall?page=\(page)") else {
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print("error with the data: \(error!)")
            return
        }
        do {
            let api = try JSONDecoder().decode(WallType.self, from:data)
            var returnFeed = WallObject()
            returnFeed.comments = api.comments
            returnFeed.last = api.last
            callback!(returnFeed)
        } catch {
            print("error decoding: \(error)")
            print(String(bytes: data, encoding: .utf8)!)
        }
    }
    //print("fetching")
    task.resume()
}
