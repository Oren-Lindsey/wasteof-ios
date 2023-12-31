//
//  Post.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 12/1/23.
//

import SwiftUI
import MarkupEditor
struct CommentsApi: Hashable, Codable {
    var comments: [CommentType]
    var last: Bool
}
struct CommentPoster: Hashable, Codable {
    var name: String
    var id: String
    var color: Optional<String>
}
struct CommentType: Hashable, Codable {
    var _id: String
    var post: String
    var poster: CommentPoster
    var parent: Optional<String>
    var content: String
    var time: Int
    var hasReplies: Bool
}
class CommentsObject: ObservableObject, Codable {
    @Published var comments: [CommentType]
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
        comments = try container.decode([CommentType].self, forKey: .comments)
        last = try container.decode(Bool.self, forKey: .last)
    }
}
struct Post: View, MarkupDelegate {
    /*func markupInput(_ view: MarkupWKWebView) {
     MarkupEditor.selectedWebView?.getHtml { html in
     //currenthtml = html!
     }
     }*/
    
    
    @StateObject var commentsState: CommentsObject
    let _id: String
    var content: String
    var time: Int
    @State var comments: Int
    var loves: Int
    var reposts: Int
    var poster: Poster
    var revisions: [Revision]
    var edited: Optional<Int> = 0
    var repost: Optional<PostType>
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
    @EnvironmentObject var session: Session
    @State var currentpage = 1
    var pinType: Bool
    /*@State var currenthtml: String = ""
     @State var startHtml: String = ""*/
    /*init() {
     MarkupEditor.style = .labeled
     let myToolbarContents = ToolbarContents(
     correction: true, formatContents: FormatContents(subSuper: false)
     )
     ToolbarContents.custom = myToolbarContents
     MarkupEditor.selectedWebView?.getHtml { html in
     print(html!)
     }
     }*/
    var body: some View {
        ScrollView {
            VStack {
                PostPreview(_id: _id, content: content, time: time, comments: comments, loves: loves, reposts: reposts, poster: poster, revisions: revisions, edited: edited, repost: repost, navigation: true, pinType: pinType, recursion: 0).environmentObject(session).padding([.bottom],1)
                Divider()
            }
            HStack{
                if comments > 1 {
                    if commentsState.last != true {
                        Text("\(comments)+ Comments")
                            .font(.title3)
                    } else {
                        Text("\(comments) Comments")
                            .font(.title3)
                    }
                } else if comments > 0 {
                    Text("\(comments) Comment")
                        .font(.title3)
                } else if comments < 1 {
                    Text("\(comments) Comments")
                        .font(.title3)
                }
                CommentEditor(id: _id, color: profileColor, parent: nil, poster: CommentPoster(name: poster.name, id: poster.id, color: nil), type: "comment").environmentObject(session)
                Spacer()
            }.onAppear() {
                fetchCommentsOnPost(id: _id, add: false, page: currentpage)
            }
            VStack {
                ForEach(commentsState.comments.indices, id: \.self) { i in
                    CommentPreview(postId: _id, _id: commentsState.comments[i]._id, /*post: commentsState.comments[i].post,*/ poster: commentsState.comments[i].poster, /*parent: commentsState.comments[i].parent,*/ parentPoster: nil, content: commentsState.comments[i].content, time: commentsState.comments[i].time, hasReplies: commentsState.comments[i].hasReplies, profileColor: profileColor, recursion: 0)
                }
                if commentsState.last != true {
                    Button {
                        currentpage += 1
                        fetchCommentsOnPost(id: _id, add: true, page: currentpage)
                    } label: {
                        Image(systemName: "text.bubble")
                        Text("Show more")
                    }.buttonStyle(.bordered).tint(profileColor)
                }
            }
        }.refreshable {
            fetchCommentsOnPost(id: _id, add: false, page: currentpage)
        }.navigationTitle("Post by @\(poster.name)").padding([.horizontal], 8)
    }
    func fetchCommentsOnPost(id: String, add: Bool, page: Int) {
    guard let url = URL(string: "https://api.wasteof.money/posts/\(id)/comments?page=\(page)") else {
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print("error with the data: \(error!)")
            return
        }
        do {
            let api = try JSONDecoder().decode(CommentsApi.self, from:data)
            DispatchQueue.main.async {
                commentsState.last = api.last
                if add {
                    commentsState.comments += api.comments
                } else {
                    commentsState.comments = api.comments
                }
                comments = commentsState.comments.count
                /*if api.last != true {
                    let newPage = page + 1
                    fetchCommentsOnPost(id: id, add: true, page: newPage)
                }*/
                //errorData = ApiError(error: "")
            }
        } catch {
            print("error decoding: \(error)")
            do {
                let apierror = try JSONDecoder().decode(ApiError.self, from:data)
                print("api error: \(apierror)")
                DispatchQueue.main.async {
                    print(apierror)
                }
            } catch {
                print("error decoding 2: \(error)")
                print(String(bytes: data, encoding: .utf8)!)
            }
        }
    }
    task.resume()
}
}
