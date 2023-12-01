//
//  PostPreview.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 11/26/23.
//

import SwiftUI
import RichText
struct PostPreview: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: Session
    let _id: String
    @State var content: String
    let time: Int
    let comments: Int
    @State var loves: Int
    let reposts: Int
    let poster: Poster
    let revisions: [Revision]
    let edited: Optional<Int>
    let repost: Optional<PostType>
    let navigation: Bool
    @State var recursion: Int
    @State private var isPresentingConfirm: Bool = false
    @State var deleted = false
    @State var reportReasonShowing = false
    @State var reason = ""
    @State var dateShown = false
    @State var loved = false //hook this up to the api
    @State var showingEdits = false
    var body: some View {
        let posttime: Date = Date(timeIntervalSince1970: TimeInterval(time / 1000))
        let pictureurl = URL(string: "https://api.wasteof.money/users/\(poster.name)/picture")
        let userLocale = Locale.autoupdatingCurrent
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
        if !deleted {
            ScrollView {
                VStack {
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
                                Image(systemName: "person.fill").tint(Color.black)
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
                        Text("@\(poster.name)").tint(colorScheme == .light ? Color.black: Color.white)
                            .font(.title2)
                        Spacer()
                        HStack {
                            Text(dateShown ? posttime.description(with: userLocale) : posttime.formatted(date: .numeric, time: .shortened))
                                .onTapGesture {
                                    dateShown.toggle()
                                    if dateShown {
                                        let pasteboard = UIPasteboard.general
                                        pasteboard.string = posttime.description(with: userLocale)
                                     
                                     }
                                }
                                .font(Font.body.italic())
                                .foregroundColor(.secondary)
                        }//.padding()
                    }
                    RichText(html: content).multilineTextAlignment(.leading)
                    if repost != nil {
                        if recursion < 4 {
                            if navigation {
                                NavigationStack {
                                    NavigationLink {
                                        Post(commentsState: CommentsObject(), _id: repost!._id, content: repost!.content, time: repost!.time, comments: repost!.comments, loves: repost!.loves, reposts: repost!.reposts, poster: repost!.poster, revisions: repost!.revisions, edited: repost?.edited, repost: repost?.repost).environmentObject(session)
                                    } label: {
                                        PostPreview(_id: repost!._id, content: repost!.content, time: repost!.time, comments: repost!.comments, loves: repost!.loves, reposts: repost!.reposts, poster: repost!.poster, revisions: repost!.revisions, edited: repost?.edited, repost: repost?.repost, navigation: true, recursion: recursion + 1).environmentObject(session)
                                    }
                                }
                            } else {
                                PostPreview(_id: repost!._id, content: repost!.content, time: repost!.time, comments: repost!.comments, loves: repost!.loves, reposts: repost!.reposts, poster: repost!.poster, revisions: repost!.revisions, edited: repost?.edited, repost: repost?.repost, navigation: false, recursion: recursion + 1).environmentObject(session)
                            }
                        } else {
                            Button {
                                recursion = 1
                            } label: {
                                Text("Show Reposts")
                            }.buttonStyle(.bordered).tint(profileColor)
                        }
                    }
                    //.padding([.bottom])
                    if revisions.count > 1 {
                        HStack {
                            /*Text("Edited at \(edittime.formatted(date: .numeric, time: .shortened))")*/
                            Button {
                                showingEdits = true
                            } label: {
                                Text("Edited")
                                //.padding([.bottom])
                                    .font(Font.body.italic())
                                    .tint(profileColor)
                            }
                            .popover(isPresented: $showingEdits) {
                                ScrollView {
                                    Text("Edits")
                                        .font(.title)
                                    ForEach(revisions.reversed(), id: \.self) { revision in
                                        let time: Date = Date(timeIntervalSince1970: TimeInterval(revision.time / 1000))
                                        VStack {
                                            Text("Time: \(time.formatted(date: .abbreviated, time: .complete))")
                                                .font(.headline)
                                            if revision.current != nil {
                                                if revision.current == true {
                                                    Text("Current")
                                                        .font(Font.body.italic())
                                                        .padding([.top], 2)
                                                }
                                            }
                                            RichText(html:revision.content)
                                        }.padding().background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    }
                                }.padding([.horizontal, .top])
                            }
                            Spacer()
                        }
                    }
                    HStack {
                        Spacer()
                        HStack {
                            //Spacer()
                            loveButton
                            CommentEditor(id: _id, color: profileColor, parent: nil, poster: CommentPoster(name: poster.name, id: poster.id, color: nil), type: String(comments))
                            Button {
                            } label: {
                                VStack {
                                    Image(systemName: "repeat")
                                    Text("\(reposts)")
                                }
                            }.tint(profileColor).buttonStyle(.bordered)
                            Spacer()
                        }
                        Spacer()
                            .frame(width: 5)
                        Menu {
                            ShareLink(item: URL(string: "https://wasteof.money/posts/\(_id)")!, message: Text("Post by @\(poster.name)"))
                            Button(role: .destructive) {
                                reportReasonShowing = true
                            } label: {
                                Label("Report Post", systemImage: "exclamationmark.bubble")
                            }
                            if session.name == poster.name {
                                Button(role: .destructive) {
                                    isPresentingConfirm = true
                                } label: {
                                    Label("Delete Post", systemImage: "trash")
                                }
                            }
                        } label: {
                            Label("", systemImage: "ellipsis.circle.fill").tint(profileColor)
                        }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                            Button("Delete Post", role: .destructive) {
                                deletePost(id: _id, token: session.token) { (success) in
                                    if success {
                                        deleted = true
                                    }
                                }
                            }
                        }
                    }.alert("Reason for reporting", isPresented: $reportReasonShowing) {
                        TextField("Enter your reason", text: $reason)
                        Button("OK") {
                            reportPost(id: _id, token: session.token, reason: reason)
                        }
                    } message: {
                        Text("Enter your reason for reporting this post.")
                    }
                }.padding()
                    .background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }.contentShape(Rectangle())
        } else {
            Text("Post deleted :(")
        }
    }
    @ViewBuilder private var loveButton: some View {
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
        if loved {
            Button {
                lovePost(_id: _id, token: session.token) { (response) in
                    loves = response.new.loves
                    loved = response.new.isLoving
                }
            } label: {
                VStack {
                    Image(systemName: "heart.fill")
                    Text("\(loves)")
                }
            }.tint(profileColor).buttonStyle(.borderedProminent).onAppear() {
                checkLoved(_id: _id, token: session.token, name: session.name) { (res) in
                    if res {
                        loved = true
                    } else {
                        loved = false
                    }
                }
            }
        } else {
            Button {
                lovePost(_id: _id, token: session.token) { (response) in
                    loves = response.new.loves
                    loved = response.new.isLoving
                }
            } label: {
                VStack {
                    Image(systemName: "heart")
                    Text("\(loves)")
                }
            }.tint(profileColor).buttonStyle(.bordered).onAppear() {
                checkLoved(_id: _id, token: session.token, name: session.name) { (res) in
                    if res {
                        loved = true
                    } else {
                        loved = false
                    }
                }
            }
        }
    }
}
struct CheckLovedResponse: Decodable {
    let loved: Bool
}
func checkLoved(_id: String, token: String, name: String, callback: @escaping (Bool) -> ()) {
    let url = URL(string: "https://api.wasteof.money/posts/\(_id)/loves/\(name)")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "GET"
    request.addValue(token, forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
        } else {
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    if dataString == "true" {
                        callback(true)
                    } else {
                        callback(false)
                    }
            }
        }
    }
    task.resume()
}
struct New: Decodable {
    let isLoving: Bool
    let loves: Int
}
struct LoveResponse: Decodable {
    let ok: String
    let new: New
}
func lovePost(_id: String, token: String, callback: ((LoveResponse) -> ())? = nil) {
    //var result: LoginResponse = LoginResponse(ok: "false", new: New(isLoving: false, loves: 0))
    let url = URL(string: "https://api.wasteof.money/posts/\(_id)/loves")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    //let postString = "username=\(username)&password=\(password)"
    /*struct LoginData: Hashable, Codable {
        let username: String
        let password: String
    }*/
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
            //result = LoginResponse(ok: "error.localizedDescription", new: New(isLoving: false, loves: 0))
        } else {
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let jsonData = dataString.data(using: .utf8)!
                var response: LoveResponse = LoveResponse(ok: "false", new: New(isLoving: false, loves: 0))
                //print(response)
                do {
                    response = try JSONDecoder().decode(LoveResponse.self, from: jsonData)
                    if response.ok == "unloved" || response.ok == "loved" {
                        /*loves = response.new.loves
                        loved = response.new.isLoving*/
                        callback!(response)
                    }
                } catch DecodingError.keyNotFound(_, _) {
                    print("something went wrong, key not found")
                    print("error: \(jsonData)")
                } catch {
                    print("something went wrong")
                    print(jsonData)
                }
            }
        }
    }
    task.resume()
}
func reportPost(id: String, token: String, reason: String) {
    let url = URL(string: "https://api.wasteof.money/posts/\(id)/report")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    //let postString = "username=\(username)&password=\(password)"
    /*struct LoginData: Hashable, Codable {
        let username: String
        let password: String
    }*/
    struct ReportBody: Hashable, Codable {
        let reason: String
        let type: String
    }
    struct ReportResponse: Hashable, Codable {
        let ok: String
    }
    let report = ReportBody(reason: reason, type: "aaa")
    let finalBody = try? JSONEncoder().encode(report)
    request.httpBody = finalBody
    request.addValue(token, forHTTPHeaderField: "Authorization")
    var res: ReportResponse = ReportResponse(ok: "no")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
            //result = LoginResponse(ok: "error.localizedDescription", new: New(isLoving: false, loves: 0))
        } else {
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let jsonData = dataString.data(using: .utf8)!
                do {
                    res = try JSONDecoder().decode(ReportResponse.self, from: jsonData)
                    print(res.ok)
                } catch DecodingError.keyNotFound(_, _) {
                    print("something went wrong, key not found")
                    print("error: \(String(decoding: jsonData, as: UTF8.self))")
                } catch {
                    print("something went wrong")
                    print(String(decoding: jsonData, as: UTF8.self))
                }
                //print(response)
                /*if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("successfully reported")
                    }
                }*/
            }
        }
    }
    task.resume()
}
func deletePost(id: String, token: String, callback: ((Bool) -> ())? = nil) {
    let url = URL(string: "https://api.wasteof.money/posts/\(id)")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "DELETE"
    //let postString = "username=\(username)&password=\(password)"
    /*struct LoginData: Hashable, Codable {
        let username: String
        let password: String
    }*/
    request.addValue(token, forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
        } else {
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("successfully deleted")
                    callback!(true)
                }
            }
        }
    }
    task.resume()
}
/*#Preview {
    PostPreview()
}*/
