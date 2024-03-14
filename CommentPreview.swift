//
//  CommentPreview.swift
//  wasteof.money
//
//  Created by Oren Lindsey on 10/27/23.
//

import SwiftUI
import RichText

struct ApiError: Hashable, Codable {
    let error: String
}
struct CommentPreview: View {
    let postId: String
    var _id: String
    var poster: CommentPoster
    var parentPoster: Optional<CommentPoster>
    var content: String
    var time: Int
    var hasReplies: Bool
    var profileColor: Color
    var recursion: Int
    @StateObject var replies: CommentsObject = CommentsObject()
    @EnvironmentObject var session: Session
    @State var dateShown = false
    @State var showMore = false
    @State var deleted = false
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
                                        .background(Color.gray)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(profileColor, lineWidth: 4)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        Text("@\(poster.name)")
                                            .font(.title2).tint(Color.white)
                                    }.padding(6).buttonStyle(PlainButtonStyle()).background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    Spacer()
                                    if parentPoster != nil {
                                        Text("Replying to @\(parentPoster?.name ?? "")").tint(profileColor)
                                    }
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
                        CommentEditor(id: postId, color: profileColor, parent: _id, poster: poster, type: "reply")
                        Spacer()
                        HStack {
                            //Spacer()
                            Spacer()
                                .frame(width: 5)
                            Menu {
                                ShareLink(item: URL(string: "https://wasteof.money/posts/\(postId)#comments-\(_id)")!, message: Text("Post by @\(poster.name)"))
                                if session.name == poster.name {
                                    Button(role: .destructive) {
                                        deleteComment(id: _id, token: session.token) { (response) in
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
                    getReplies(commentId: _id)
                }
            }
            
            HStack {
                VStack {
                    ForEach(replies.comments.indices, id: \.self) {i in
                        if recursion < 3 || showMore {
                            CommentPreview(postId: postId, _id: replies.comments[i]._id, poster: replies.comments[i].poster, parentPoster: poster, content: replies.comments[i].content, time: replies.comments[i].time, hasReplies: replies.comments[i].hasReplies, profileColor: profileColor, recursion: recursion + 1).frame(maxWidth: 300).environmentObject(session)
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
    func getReplies(commentId: String) {
        guard let url = URL(string: "https://api.wasteof.money/comments/\(commentId)/replies") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("error with the data: \(error!)")
                return
            }
            do {
                let api = try JSONDecoder().decode(CommentsObject.self, from:data)
                DispatchQueue.main.async {
                    replies.last = api.last
                    replies.comments = api.comments
                }
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
}
