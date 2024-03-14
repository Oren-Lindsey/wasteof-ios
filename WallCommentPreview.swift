//
//  WallCommentPreview.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 1/8/24.
//

import SwiftUI
import RichText

struct WallCommentPreview: View {
    @EnvironmentObject var session: Session
    var id: String
    var parent: Optional<String>
    var content: String
    var wall: WallUser
    var poster: CommentPoster
    var time: Int
    var hasReplies: Bool
    var recursion: Int
    @StateObject var replies: WallRepliesObject = WallRepliesObject()
    @State var dateShown = false
    @State var showMore = false
    @State var deleted = false
    var profileColor: Color {
        switch poster.color {
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
        let posttime: Date = Date(timeIntervalSince1970: TimeInterval(time / 1000))
        let pictureurl = URL(string: "https://api.wasteof.money/users/\(poster.name)/picture")
        let userLocale = Locale.autoupdatingCurrent
        VStack {
            VStack {
                if !deleted {
                    HStack {
                        NavigationStack {
                            NavigationLink {
                                User(name: poster.name, navigationType: "stack")
                            } label: {
                                HStack {
                                    HStack {
                                        AsyncImage(
                                            url: pictureurl,
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
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(profileColor, lineWidth: 4)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        Text("@\(poster.name)")
                                            .font(.title2).tint(Color.white)
                                    }.padding(6).buttonStyle(PlainButtonStyle()).background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    Spacer()
                                }
                            }
                        }
                        HStack {
                            Text(dateShown ? posttime.description(with: userLocale) : posttime.formatted(date: .numeric, time: .shortened))
                                .onTapGesture {
                                    dateShown.toggle()
                                }
                                .font(Font.body.italic())
                                .foregroundColor(.secondary)
                        }
                    }
                    RichText(html: content).multilineTextAlignment(.leading)
                    HStack {
                        WallCommentButton(type: "reply", username: wall.name, parent: id, color: profileColor).onPost {
                            print("posted a new comment!")
                            getReplies(commentId: id) { (repliesResults) in
                                DispatchQueue.main.async {
                                    replies.comments = repliesResults.comments
                                    replies.last = repliesResults.last
                                }
                            }
                        }
                        Spacer()
                        HStack {
                            Spacer()
                                .frame(width: 5)
                            Menu {
                                ShareLink(item: URL(string: "https://wasteof.money/users/\(wall.name)/#comments-\(id)")!, message: Text("Comment by @\(poster.name)"))
                                if poster.name == session.name {
                                    Button(role:.destructive) {
                                        deleteComment(id: id, token: session.token) { (response) in
                                            if response.ok == "comment deleted" {
                                                deleted = true
                                            }
                                        }
                                    } label: {
                                        Label("Delete Comment", systemImage: "trash")
                                    }
                                }
                            } label: {
                                Label("", systemImage: "ellipsis.circle.fill").tint(profileColor)
                            }
                        }
                    }
                } else {
                    Text("Comment deleted")
                }
            }.padding().background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous)).onAppear() {
                if hasReplies {
                    getReplies(commentId: id) { (repliesResults) in
                        DispatchQueue.main.async {
                            replies.comments = repliesResults.comments
                            replies.last = repliesResults.last
                        }
                    }
                }
            }
            
            HStack {
                VStack {
                    ForEach(replies.comments.indices, id: \.self) {i in
                        let reply = replies.comments[i]
                        if recursion < 3 || showMore {
                            WallCommentPreview(id: reply._id, parent: reply.parent, content: reply.content, wall: reply.wall, poster: reply.poster, time: reply.time, hasReplies: reply.hasReplies, recursion: recursion + 1).frame(maxWidth: 300).environmentObject(session)
                            Spacer()
                        } else {
                            Button {
                                showMore = true
                            } label: {
                                Image(systemName: "text.bubble")
                                Text("Show More")
                            }.buttonStyle(.bordered).tint(profileColor)
                        }
                    }
                }
                Spacer()
            }
            if recursion < 1 {
                Spacer()
            }
        }
    }
}
struct WallReplyType: Hashable, Codable {
    var _id: String
    var wall: WallUser
    var poster: CommentPoster
    var parent: String
    var content: String
    var time: Int
    var top: String
    var hasReplies: Bool
}
class WallRepliesObject: ObservableObject, Codable {
    @Published var comments: [WallReplyType]
    @Published var last: Bool
    enum CodingKeys: CodingKey {
        case comments, last
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(comments, forKey: .comments)
        try container.encode(last, forKey: .last)
    }
    init() {
        self.comments = []
        self.last = true
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        comments = try container.decode([WallReplyType].self, forKey: .comments)
        last = try container.decode(Bool.self, forKey: .last)
    }
}
func getReplies(commentId: String, callback: ((WallRepliesObject) -> ())? = nil) {
    guard let url = URL(string: "https://api.wasteof.money/comments/\(commentId)/replies") else {
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print("error with the data: \(error!)")
            return
        }
        do {
            let api = try JSONDecoder().decode(WallRepliesObject.self, from:data)
            callback!(api)
        } catch {
            print("error decoding: \(error)")
            do {
                let apierror = try JSONDecoder().decode(ApiError.self, from:data)
                print("api error: \(apierror)")
            } catch {
                print("error decoding 2: \(error)")
                print(String(bytes: data, encoding: .utf8)!)
            }
        }
    }
    task.resume()
}
struct DeleteResponse: Hashable, Codable {
    var ok: String
}
func deleteComment(id: String, token: String, callback: ((DeleteResponse) -> ())? = nil) {
    let url = URL(string: "https://api.wasteof.money/comments/\(id)")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "DELETE"
    request.addValue(token, forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data, error == nil else {
            print("error with the data: \(error!)")
            return
        }
        if let error = error {
            print("Error took place \(error)")
        } else {
            if let httpResponse = response as? HTTPURLResponse {
                do {
                    let api = try JSONDecoder().decode(DeleteResponse.self, from: data)
                    callback!(api)
                } catch {
                    print("error decoding: \(error)")
                }
            }
        }
    }
    task.resume()
}
