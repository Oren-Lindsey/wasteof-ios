//
//  Messages.swift
//  wasteof.money
//
//  Created by Oren Lindsey on 11/3/23.
//

import SwiftUI
import RichText
struct MessagesObject: Hashable, Codable {
    var unread: Optional<[Message]>
    var read: Optional<[Message]>
    var last: Bool
    enum CodingKeys: String, CodingKey {
            case unread
            case read
            case last
        }
    /*init() {
        self.last = true
        self.unread = []
    }
    static func == (lhs: MessagesObject, rhs: MessagesObject) -> Bool {
        return lhs.unread == rhs.unread && lhs.last == rhs.last
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(unread)
        hasher.combine(last)
    }*/
}
class MessagesStateObject: ObservableObject {
    @Published var last: Bool
    @Published var unread: [Message]
    init() {
        self.last = true
        self.unread = []
    }
}
struct Message: Hashable, Codable, Identifiable {
    let id: UUID = UUID()
    var _id: String
    var data: Optional<MessageData>
    var read: Bool
    var time: Int
    var to: MessageReceiver
    var type: String
    var top: Optional<String>

    enum CodingKeys: String, CodingKey {
        case _id
        case data
        case read
        case time
        case to
        case type
        case top
    }
}

struct MessageData: Hashable, Codable {
    var actor: Optional<MessageActor>
    var comment: Optional<MessagesCommentType>
    var post: Optional<PostType>
    var wall: Optional<WallUser>
    var content: Optional<String>
    enum CodingKeys: String, CodingKey {
            case actor
            case comment
            case post
            case wall
            case content
        }
}
struct MessagesCommentType: Hashable, Codable {
    var _id: String
    var post: Optional<String>
    var poster: CommentPoster
    var wall: Optional<WallUser>
    var parent: Optional<String>
    var content: String
    var time: Int
    var hasReplies: Bool
}
struct MessageActor: Hashable, Codable {
    let name: String
    let id: String
    /*enum CodingKeys: String, CodingKey {
        case name
        case id
    }*/
}
struct MessageReceiver: Hashable, Codable {
    let name: String
    let id: String
    /*enum CodingKeys: String, CodingKey {
        case name
        case id
    }*/
}
struct Messages: View {
    @EnvironmentObject var session: Session
    @StateObject var messagesState: MessagesStateObject
    @State var page = 1
    @State var read = false
    var body: some View {
            NavigationStack {
                VStack {
                    List {
                        if messagesState.unread.count > 0 {
                            ForEach(messagesState.unread.indices, id: \.self) { i in
                                let profilecolor: Color = {
                                    switch  messagesState.unread[i].data?.comment?.poster.color {
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
                                    }}()
                                VStack {
                                    if  messagesState.unread[i].type == "comment_reply" {
                                        if  messagesState.unread[i].data?.comment != nil &&  messagesState.unread[i].data?.post != nil {
                                            HStack {
                                                Text("@\( messagesState.unread[i].data?.actor?.name ?? "") replied to your comment").multilineTextAlignment(.leading)
                                                Spacer()
                                            }
                                            NavigationLink {
                                                Post(commentsState: CommentsObject(), _id:  messagesState.unread[i].data?.post?._id ?? "", content: messagesState.unread[i].data?.post?.content ?? "", time: messagesState.unread[i].data?.post?.time ?? 0, comments: messagesState.unread[i].data?.post?.comments ?? 0, loves: messagesState.unread[i].data?.post?.loves ?? 0, reposts: messagesState.unread[i].data?.post?.reposts ?? 0, poster: messagesState.unread[i].data?.post?.poster ?? Poster(name: "", id: "", color: ""), revisions: messagesState.unread[i].data?.post?.revisions ?? [], edited: messagesState.unread[i].data?.post?.edited ?? 0, repost: messagesState.unread[i].data?.post?.repost ?? nil, pinType: true).environmentObject(session)
                                            } label: {
                                                CommentPreview(postId: messagesState.unread[i].data?.post?._id ?? "", _id: messagesState.unread[i].data?.comment?._id ?? "", poster: messagesState.unread[i].data?.comment?.poster ?? CommentPoster(name: "", id: "", color: nil), /*parent: messagesState.unread[i].data?.comment?.parent ?? "",*/ parentPoster: nil, content: messagesState.unread[i].data?.comment?.content ?? "", time: messagesState.unread[i].data?.comment?.time ?? 0, hasReplies: messagesState.unread[i].data?.comment?.hasReplies ?? false, profileColor: profilecolor, recursion: 3).environmentObject(session)
                                            }
                                        } else {
                                            HStack {
                                                Text("@\(messagesState.unread[i].data?.actor?.name ?? "") replied to your comment, but the comment was deleted").multilineTextAlignment(.leading)
                                                Spacer()
                                            }
                                        }
                                    } else if messagesState.unread[i].type == "follow" {
                                        HStack {
                                            Text("@\(messagesState.unread[i].data?.actor?.name ?? "") is now following you")
                                            Spacer()
                                        }
                                    } else if messagesState.unread[i].type == "admin_notification" {
                                        let time: Date = Date(timeIntervalSince1970: TimeInterval(messagesState.unread[i].time / 1000))
                                        HStack {
                                            Text("Admin message: \"\(messagesState.unread[i].data?.content ?? "")\" at \(time.formatted(date: .numeric, time: .shortened))").bold().font(.title3)
                                            Spacer()
                                        }
                                    } else if messagesState.unread[i].type == "comment" {
                                        if messagesState.unread[i].data?.comment != nil && messagesState.unread[i].data?.post != nil {
                                            HStack {
                                                Text("@\(messagesState.unread[i].data?.actor?.name ?? "") commented on your post")
                                                Spacer()
                                            }
                                            NavigationLink {
                                                Post(commentsState: CommentsObject(), _id: messagesState.unread[i].data?.post?._id ?? "", content: messagesState.unread[i].data?.post?.content ?? "", time: messagesState.unread[i].data?.post?.time ?? 0, comments: messagesState.unread[i].data?.post?.comments ?? 0, loves: messagesState.unread[i].data?.post?.loves ?? 0, reposts: messagesState.unread[i].data?.post?.reposts ?? 0, poster: messagesState.unread[i].data?.post?.poster ?? Poster(name: "", id: "", color: ""), revisions: messagesState.unread[i].data?.post?.revisions ?? [], edited: messagesState.unread[i].data?.post?.edited ?? 0, repost: messagesState.unread[i].data?.post?.repost ?? nil, pinType: true).environmentObject(session)
                                            } label: {
                                                CommentPreview(postId: messagesState.unread[i].data?.post?._id ?? "", _id: messagesState.unread[i].data?.comment?._id ?? "", poster: messagesState.unread[i].data?.comment?.poster ?? CommentPoster(name: "", id: "", color: nil), /*parent: messagesState.unread[i].data?.comment?.parent ?? "",*/ parentPoster: nil, content: messagesState.unread[i].data?.comment?.content ?? "", time: messagesState.unread[i].data?.comment?.time ?? 0, hasReplies: messagesState.unread[i].data?.comment?.hasReplies ?? false, profileColor: profilecolor, recursion: 3).environmentObject(session)
                                            }
                                        } else {
                                            HStack {
                                                Text("@\(messagesState.unread[i].data?.actor?.name ?? "") commented on your post, but either the comment or the post was deleted :(")
                                                Spacer()
                                            }
                                        }
                                    } else if messagesState.unread[i].type == "post_mention" {
                                        if messagesState.unread[i].data?.post != nil {
                                            HStack {
                                                Text("@\(messagesState.unread[i].data?.actor?.name ?? "") mentioned you in their post")
                                                Spacer()
                                            }
                                            NavigationLink {
                                                Post(commentsState: CommentsObject(), _id: messagesState.unread[i].data?.post?._id ?? "", content: messagesState.unread[i].data?.post?.content ?? "", time: messagesState.unread[i].data?.post?.time ?? 0, comments: messagesState.unread[i].data?.post?.comments ?? 0, loves: messagesState.unread[i].data?.post?.loves ?? 0, reposts: messagesState.unread[i].data?.post?.reposts ?? 0, poster: messagesState.unread[i].data?.post?.poster ?? Poster(name: "", id: "", color: ""), revisions: messagesState.unread[i].data?.post?.revisions ?? [], edited: messagesState.unread[i].data?.post?.edited ?? 0, repost: messagesState.unread[i].data?.post?.repost ?? nil, currentpage: 1, pinType: true).environmentObject(session)
                                            } label: {
                                                PostPreview(_id: messagesState.unread[i].data?.post?._id ?? "", content: messagesState.unread[i].data?.post?.content ?? "", time: messagesState.unread[i].data?.post?.time ?? 0, comments: messagesState.unread[i].data?.post?.comments ?? 0, loves: messagesState.unread[i].data?.post?.loves ?? 0, reposts: messagesState.unread[i].data?.post?.reposts ?? 0, poster: messagesState.unread[i].data?.post?.poster ?? Poster(name: "", id: "", color: ""), revisions: messagesState.unread[i].data?.post?.revisions ?? [], edited: messagesState.unread[i].data?.post?.edited ?? 0, repost: messagesState.unread[i].data?.post?.repost ?? nil, navigation: false,pinType: true, recursion: 0).environmentObject(session)
                                            }
                                        } else {
                                            HStack {
                                                Text("@\(messagesState.unread[i].data?.actor?.name ?? "") mentioned you in a deleted post")
                                                Spacer()
                                            }
                                        }
                                        
                                    } else if messagesState.unread[i].type == "comment_mention" {
                                        if messagesState.unread[i].data?.comment != nil && messagesState.unread[i].data?.post != nil {
                                            HStack {
                                                Text("@\(messagesState.unread[i].data?.actor?.name ?? "") mentioned you in their comment")
                                                Spacer()
                                            }
                                            NavigationLink {
                                                Post(commentsState: CommentsObject(), _id: messagesState.unread[i].data?.post?._id ?? "", content: messagesState.unread[i].data?.post?.content ?? "", time: messagesState.unread[i].data?.post?.time ?? 0, comments: messagesState.unread[i].data?.post?.comments ?? 0, loves: messagesState.unread[i].data?.post?.loves ?? 0, reposts: messagesState.unread[i].data?.post?.reposts ?? 0, poster: messagesState.unread[i].data?.post?.poster ?? Poster(name: "", id: "", color: ""), revisions: messagesState.unread[i].data?.post?.revisions ?? [], edited: messagesState.unread[i].data?.post?.edited ?? 0, repost: messagesState.unread[i].data?.post?.repost ?? nil, pinType: true).environmentObject(session)
                                            } label: {
                                                CommentPreview(postId: messagesState.unread[i].data?.post?._id ?? "", _id: messagesState.unread[i].data?.comment?._id ?? "", poster: messagesState.unread[i].data?.comment?.poster ?? CommentPoster(name: "", id: "", color: nil), /*parent: messagesState.unread[i].data?.comment?.parent ?? "",*/ parentPoster: nil, content: messagesState.unread[i].data?.comment?.content ?? "", time: messagesState.unread[i].data?.comment?.time ?? 0, hasReplies: messagesState.unread[i].data?.comment?.hasReplies ?? false, profileColor: profilecolor, recursion: 3).environmentObject(session)
                                            }
                                        } else {
                                            HStack {
                                                Text("@\(messagesState.unread[i].data?.actor?.name ?? "") mentioned you in their comment, but the comment was deleted :(")
                                                Spacer()
                                            }
                                        }
                                    } else if messagesState.unread[i].type == "repost" {
                                        if messagesState.unread[i].data?.post != nil {
                                            HStack {
                                                Text("@\(messagesState.unread[i].data?.actor?.name ?? "") reposted your post")
                                                Spacer()
                                            }
                                            NavigationLink {
                                                Post(commentsState: CommentsObject(), _id: messagesState.unread[i].data?.post?._id ?? "", content: messagesState.unread[i].data?.post?.content ?? "", time: messagesState.unread[i].data?.post?.time ?? 0, comments: messagesState.unread[i].data?.post?.comments ?? 0, loves: messagesState.unread[i].data?.post?.loves ?? 0, reposts: messagesState.unread[i].data?.post?.reposts ?? 0, poster: messagesState.unread[i].data?.post?.poster ?? Poster(name: "", id: "", color: ""), revisions: messagesState.unread[i].data?.post?.revisions ?? [], edited: messagesState.unread[i].data?.post?.edited ?? 0, repost: messagesState.unread[i].data?.post?.repost ?? nil, currentpage: 1, pinType: true).environmentObject(session)
                                            } label: {
                                                PostPreview(_id: messagesState.unread[i].data?.post?._id ?? "", content: messagesState.unread[i].data?.post?.content ?? "", time: messagesState.unread[i].data?.post?.time ?? 0, comments: messagesState.unread[i].data?.post?.comments ?? 0, loves: messagesState.unread[i].data?.post?.loves ?? 0, reposts: messagesState.unread[i].data?.post?.reposts ?? 0, poster: messagesState.unread[i].data?.post?.poster ?? Poster(name: "", id: "", color: ""), revisions: messagesState.unread[i].data?.post?.revisions ?? [], edited: messagesState.unread[i].data?.post?.edited ?? 0, repost: messagesState.unread[i].data?.post?.repost ?? nil, navigation: false, pinType: true, recursion: 0).environmentObject(session)
                                            }
                                        } else {
                                            HStack {
                                                Text("@\(messagesState.unread[i].data?.actor?.name ?? "") reposted your post, but the post was deleted")
                                                Spacer()
                                            }
                                        }
                                    } else if messagesState.unread[i].type == "wall_comment" {
                                       if messagesState.unread[i].data?.comment != nil {
                                               HStack {
                                                   Text("@\(messagesState.unread[i].data?.actor?.name ?? "") commented on your wall")
                                                   Spacer()
                                               }
                                               NavigationLink {
                                                   Wall(username: messagesState.unread[i].data?.wall?.name ?? "").environmentObject(session)
                                               } label: {
                                                   WallCommentPreview(id: messagesState.unread[i].data?.comment?._id ?? "", parent: messagesState.unread[i].data?.comment?.parent ?? "", content: messagesState.unread[i].data?.comment?.content ?? "", wall: messagesState.unread[i].data?.wall ?? WallUser(name: "", id: ""), poster: messagesState.unread[i].data?.comment?.poster ?? CommentPoster(name: "", id: "", color: nil), time: messagesState.unread[i].data?.comment?.time ?? 0, hasReplies: messagesState.unread[i].data?.comment?.hasReplies ?? false, recursion: 1).environmentObject(session)
                                               }
                                       } else {
                                           HStack {
                                               Text("@\(messagesState.unread[i].data?.actor?.name ?? "") commented on your wall, but the comment was deleted :(")
                                               Spacer()
                                           }
                                       }
                                    } else if messagesState.unread[i].type == "wall_comment_mention" {
                                        if messagesState.unread[i].data?.comment != nil {
                                               HStack {
                                                   if messagesState.unread[i].data?.wall?.name == session.name {
                                                       Text("@\(messagesState.unread[i].data?.actor?.name ?? "") mentioned you on your wall")
                                                   } else {
                                                       Text("@\(messagesState.unread[i].data?.actor?.name ?? "") mentioned you on @\(messagesState.unread[i].data?.wall?.name ?? "")'s wall")
                                                   }
                                                   Spacer()
                                               }
                                               NavigationLink {
                                                   Wall(username: messagesState.unread[i].data?.wall?.name ?? "").environmentObject(session)
                                               } label: {
                                                   WallCommentPreview(id: messagesState.unread[i].data?.comment?._id ?? "", parent: messagesState.unread[i].data?.comment?.parent ?? "", content: messagesState.unread[i].data?.comment?.content ?? "", wall: messagesState.unread[i].data?.wall ?? WallUser(name: "", id: ""), poster: messagesState.unread[i].data?.comment?.poster ?? CommentPoster(name: "", id: "", color: nil), time: messagesState.unread[i].data?.comment?.time ?? 0, hasReplies: messagesState.unread[i].data?.comment?.hasReplies ?? false, recursion: 1).environmentObject(session)
                                               }
                                       } else {
                                           HStack {
                                               if messagesState.unread[i].data?.wall?.name == session.name {
                                                   Text("@\(messagesState.unread[i].data?.actor?.name ?? "") mentioned you on your wall, but the comment was deleted :(")
                                               } else {
                                                   Text("@\(messagesState.unread[i].data?.actor?.name ?? "") mentioned you on @\(messagesState.unread[i].data?.wall?.name ?? "")'s wall, but the comment was deleted :(")
                                               }
                                               Spacer()
                                           }
                                       }
                                    } else if messagesState.unread[i].type == "wall_comment_reply" {
                                       if messagesState.unread[i].data?.comment != nil {
                                               HStack {
                                                   if messagesState.unread[i].data?.wall?.name == session.name {
                                                       Text("@\(messagesState.unread[i].data?.actor?.name ?? "") replied to your comment on your wall")
                                                   } else {
                                                       Text("@\(messagesState.unread[i].data?.actor?.name ?? "") replied to your comment on @\(messagesState.unread[i].data?.wall?.name ?? "")'s wall")
                                                   }
                                                   Spacer()
                                               }
                                               NavigationLink {
                                                   Wall(username: messagesState.unread[i].data?.wall?.name ?? "").environmentObject(session)
                                               } label: {
                                                   WallCommentPreview(id: messagesState.unread[i].data?.comment?._id ?? "", parent: messagesState.unread[i].data?.comment?.parent ?? "", content: messagesState.unread[i].data?.comment?.content ?? "", wall: messagesState.unread[i].data?.wall ?? WallUser(name: "", id: ""), poster: messagesState.unread[i].data?.comment?.poster ?? CommentPoster(name: "", id: "", color: nil), time: messagesState.unread[i].data?.comment?.time ?? 0, hasReplies: messagesState.unread[i].data?.comment?.hasReplies ?? false, recursion: 1).environmentObject(session)
                                               }
                                       } else {
                                           HStack {
                                               if messagesState.unread[i].data?.wall?.name == session.name {
                                                   Text("@\(messagesState.unread[i].data?.actor?.name ?? "") replied to your comment on your wall, but the comment was deleted :(")
                                               } else {
                                                   Text("@\(messagesState.unread[i].data?.actor?.name ?? "") replied to your comment on @\(messagesState.unread[i].data?.wall?.name ?? "")'s wall, but the comment was deleted :(")
                                               }
                                               Spacer()
                                           }
                                       }
                                    } else {
                                        HStack {
                                            Text("Unhandled message type: \(messagesState.unread[i].type)")
                                            Spacer()
                                        }
                                    }
                                }.listRowSeparator(.hidden).padding().background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }.onDelete(perform: delete)
                        } else {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("No messages :)")
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        if messagesState.last != true {
                            Button {
                                page += 1
                                fetchMessages(token: session.token, page: page, read: read) { messages in
                                    let messagesArray = messages.unread ?? []
                                    if messagesArray.count > 0 {
                                        messagesState.unread = messagesArray
                                    }
                                    messagesState.last = messages.last
                                }
                            } label: {
                                Text("Show more")
                            }.buttonStyle(.bordered).tint(.accentColor)
                        }
                    }.listStyle(.plain)
                }.toolbar {
                    Button {
                        read.toggle()
                        fetchMessages(token: session.token, page: page, read: read) { messages in
                            var messagesArray: [Message]
                            if read {
                                messagesArray = messages.read ?? []
                            } else {
                                messagesArray = messages.unread ?? []
                            }
                            messagesState.unread = messagesArray
                            messagesState.last = messages.last
                        }
                    } label: {
                        Label(read ? "Read" : "Unread", systemImage: read ? "eye.fill" : "eye")
                    }
                    EditButton()
                }.navigationTitle(read ? "Read Messages" : "Unread Messages")
            }.refreshable {
                page = 1
                fetchMessages(token: session.token, page: page, read: read) { messages in
                    var messagesArray: [Message]
                    if read {
                        messagesArray = messages.read ?? []
                    } else {
                        messagesArray = messages.unread ?? []
                    }
                    messagesState.unread = messagesArray
                    messagesState.last = messages.last
                }
            }
    }
    
    func delete(at offsets: IndexSet) {
        for n in offsets {
            let messageid = messagesState.unread[n]._id
            let messageState = messagesState.unread[n].read
            messagesState.unread.remove(at: n)
            markMessage(id: messageid, token: session.token, read: !messageState)
            /*if messagesState.unread.count < 14 && oldCount > 14 {
                fetchMessages(token: session.token, page: 1, add: false)
            }*/
        }
    }
    func markMessage(id: String, token: String, read: Bool) {
        struct messagesList: Hashable, Codable {
            var messages: [String]
        }
        let messageToMark = messagesList(messages: [id])
        guard let url = URL(string: "https://api.wasteof.money/messages/mark/\(read == true ? "read" : "unread")") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //let postString = "username=\(username)&password=\(password)"
        /*struct LoginData: Hashable, Codable {
            let username: String
            let password: String
        }*/
        struct MarkResponse: Hashable, Codable {
            var ok: String
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let body = messageToMark
        let finalBody = try? JSONEncoder().encode(body)
        request.httpBody = finalBody
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                //result = LoginResponse(ok: "error.localizedDescription", new: New(isLoving: false, loves: 0))
            } else {
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    let jsonData = dataString.data(using: .utf8)!
                    var response: MarkResponse = MarkResponse(ok: "no")
                    //print(response)
                    do {
                        response = try JSONDecoder().decode(MarkResponse.self, from: jsonData)
                        print(response.ok)
                    } catch DecodingError.keyNotFound(_, _) {
                        print("something went wrong, key not found")
                        print("error: \(String(decoding: jsonData, as: UTF8.self))")
                    } catch {
                        print("something went wrong")
                        print(String(decoding: jsonData, as: UTF8.self))
                    }
                }
            }
        }
        task.resume()
    }
}
