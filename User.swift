//
//  User.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 12/30/23.
//

import SwiftUI
import Foundation
struct UserFeed: Hashable, Codable {
    var posts: [PostType]
    var pinned: [PostType]
    var last: Bool
}
struct User: View {
    var name: String
    var navigationType: String
    @State var page = 1
    @State var userData: UserDecoder = UserDecoder(name: "", id: "", bio: "", verified: false, permissions: Permissions(admin: false, banned: false), beta: false, color: "indigo", links: [], history: History(joined: 0), stats: UserStats(followers: 0, following: 0, posts: 0), online: false)
    @State var userPosts: UserFeed = UserFeed(posts: [], pinned: [], last: false)
    @EnvironmentObject var session: Session
    @State var isloading: Bool = false
    @State var following = false
    @State var followsYou = false
    @State var checkedFollowsYou = false
    @State var editBio = ""
    var profileColor: Color {
        switch userData.color {
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
        if userData.id == "" {
            loader
        } else {
            NavigationStack {
                ScrollView {
                    header.overlay(
                        Rectangle()
                            .frame(height: 4)
                            .foregroundColor(profileColor),
                        alignment: .bottom).ignoresSafeArea()
                    stats
                    HStack {
                        NavigationStack {
                            NavigationLink {
                                Wall(username: userData.name, color: profileColor).environmentObject(session)
                            } label: {
                                Label("Wall", systemImage: "person.bubble")
                            }.buttonStyle(.bordered).tint(profileColor)
                        }.padding([.horizontal])
                        Spacer()
                    }
                    if $userPosts.posts.count < 1 && userPosts.last == false {
                        ProgressView().onAppear() {
                            getUserPosts(name: name, page: page) { (posts) in
                                userPosts = posts
                            }
                        }
                    } else {
                        if userPosts.posts.count < 1 && userPosts.last == true {
                            Text("This user hasn't posted yet :(")
                        } else {
                            if userPosts.pinned.count > 0 {
                                HStack {
                                    Image(systemName: "pin")
                                    Text("Pinned Posts (\(userPosts.pinned.count))")
                                    Spacer()
                                }.padding()
                                ForEach(userPosts.pinned.indices, id: \.self) { i in
                                    let post = userPosts.pinned[i]
                                    NavigationLink {
                                        Post(commentsState: CommentsObject(), _id: post._id, content: post.content, time: post.time, comments: post.comments, loves: post.loves, reposts: post.reposts, poster: post.poster, revisions: post.revisions, repost: post.repost, pinType: false)
                                    } label: {
                                        PostPreview(_id: post._id, content: post.content, time: post.time, comments: post.comments, loves: post.loves, reposts: post.reposts, poster: Poster(name: post.poster.name, id: post.poster.id, color: userData.color), revisions: post.revisions, edited: post.edited, repost: post.repost, navigation: true,pinType: false, recursion: 1).environmentObject(session).frame(minHeight: 100).padding([.horizontal], 5)
                                    }
                                }
                                Divider()
                            }
                            HStack {
                                Label("Posts (\(userPosts.posts.count) / \(userData.stats.posts))", systemImage: "note.text").font(.title2)
                                Spacer()
                            }.padding()
                            ForEach(userPosts.posts.indices, id: \.self) { i in
                                let post = userPosts.posts[i]
                                NavigationLink {
                                    Post(commentsState: CommentsObject(), _id: post._id, content: post.content, time: post.time, comments: post.comments, loves: post.loves, reposts: post.reposts, poster: post.poster, revisions: post.revisions, repost: post.repost, pinType: true)
                                } label: {
                                    PostPreview(_id: post._id, content: post.content, time: post.time, comments: post.comments, loves: post.loves, reposts: post.reposts, poster: Poster(name: post.poster.name, id: post.poster.id, color: userData.color), revisions: post.revisions, edited: post.edited, repost: post.repost, navigation: true,pinType: true, recursion: 1).environmentObject(session).frame(minHeight: 100).padding([.horizontal], 5)
                                }
                            }
                            if userPosts.last != true {
                                Button {
                                    page += 1
                                    getUserPosts(name: name, page: page) { (posts) in
                                        userPosts.posts += posts.posts
                                        userPosts.last = posts.last
                                    }
                                } label: {
                                    Image(systemName: "text.bubble")
                                    Text("Show more")
                                }.buttonStyle(.bordered).tint(profileColor)
                            }
                        }
                    }
                }.ignoresSafeArea(edges: [.top])
            }.refreshable {
                getUserPosts(name: name, page: page) { (posts) in
                    userPosts = posts
                }
                getUserData(username: name) { (user) in
                    userData = user
                }
            }
        }
    }
    @ViewBuilder private var loader: some View {
        ProgressView().onAppear() {
            getUserData(username: name) { (user) in
                editBio = user.bio
                userData = user
            }
            getUserPosts(name: name, page: page) { (posts) in
                userPosts = posts
            }
        }
    }
    @ViewBuilder private var stats: some View {
        let historyObject = userData.history ?? History(joined: 0)
        let time = historyObject.joined
        let jointime: Date = Date(timeIntervalSince1970: TimeInterval(time / 1000))
        let dateresult = jointime.isBetween(Date(timeIntervalSince1970: TimeInterval(1623470400)), Date(timeIntervalSince1970: TimeInterval(1639285200)))
        if userData.name == session.name {
            TextField("Edit bio", text: $editBio).textFieldStyle(.roundedBorder).overlay(
                RoundedRectangle(cornerRadius: 8).stroke(Color.gray)).submitLabel(.done).padding([.horizontal], 5).onSubmit {
                    updateBio(name: session.name, content: editBio, token: session.token) { (response) in
                        userData.bio = response.bio
                    }
                }
            } else {
                if userData.bio.count > 0 {
                    Text("\"\(userData.bio)\"").font(.callout).padding(1).foregroundColor(.white)
                }
            }
            Spacer()
            HStack {
                if jointime.timeIntervalSince1970 > 1 {
                    VStack {
                        Label(jointime.formatted(date: .numeric, time: .omitted), systemImage: "clock").bold()
                        Text("joined")
                    }.padding(8).background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                VStack {
                    Label("\(userData.stats.followers)", systemImage: "person").bold()
                    Text("followers")
                }.padding(8).background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack {
                    Label("\(userData.stats.following)", systemImage: "person").bold()
                    Text("following")
                }.padding(8).background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack {
                    Label("\(userData.stats.posts)", systemImage: "note.text").bold()
                    Text("posts")
                }.padding(8).background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
    }
    @ViewBuilder private var header: some View {
        let historyObject = userData.history ?? History(joined: 0)
        let time = historyObject.joined
        let jointime: Date = Date(timeIntervalSince1970: TimeInterval(time / 1000))
        let dateresult = jointime.isBetween(Date(timeIntervalSince1970: TimeInterval(1623470400)), Date(timeIntervalSince1970: TimeInterval(1639285200)))
        ZStack {
            Rectangle().foregroundColor(.black).frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()
            AsyncImage(url: URL(string:"https://api.wasteof.money/users/\(userData.name)/banner")) { phase in
                switch phase {
                case .empty:
                    VStack {
                        HStack {
                            ProgressView().frame(minWidth: UIScreen.main.bounds.width)
                        }.frame(minHeight: UIScreen.main.bounds.height)
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .opacity(0.8)
                        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: navigationType == "stack" ? 200 : 150)
                        .shadow(radius: 8)
                case .failure:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }.ignoresSafeArea().clipped().frame(maxHeight: navigationType == "stack" ? 200 : 150)
                VStack {
                    HStack {
                        VStack {
                            
                            AsyncImage(
                                url: URL(string: "https://api.wasteof.money/users/\(userData.name)/picture"),
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
                            .frame(width: 65, height: 65)
                            .background(Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(self.profileColor, lineWidth: 4)
                            )
                            .padding([.leading])
                            Spacer()
                        }
                            VStack {
                                HStack {
                                    Text("@\(userData.name)").font(.largeTitle)
                                    Spacer()
                                }
                                HStack {
                                    if userData.verified {
                                        Image(systemName: "checkmark.seal.fill")
                                    }
                                    if userData.permissions.admin {
                                        Image(systemName: "checkmark.shield.fill")
                                    }
                                    if userData.beta {
                                        Image(systemName: "testtube.2")
                                    }
                                    if dateresult {
                                        if userData.name == "jeffalo" {
                                            Image(systemName: "crown.fill")
                                        } else {
                                            Image(systemName: "crown")
                                        }
                                    }
                                    Spacer()
                                }
                                Spacer()
                        }
                        VStack {
                            if following {
                                    Button {
                                        followUser(name: userData.name, token: session.token) { (result) in
                                            userData.stats.followers = result.new.followers
                                            userData.stats.following = result.new.following
                                            following = result.new.isFollowing
                                        }
                                    } label: {
                                        Label("Unfollow", systemImage: "person.badge.plus")
                                    }.tint(profileColor).buttonStyle(.bordered).background(RoundedRectangle(cornerRadius: 8, style: .continuous).foregroundColor(.black).opacity(0.5))
                            } else {
                                Button {
                                    followUser(name: userData.name, token: session.token) { (result) in
                                        userData.stats.followers = result.new.followers
                                        userData.stats.following = result.new.following
                                        following = result.new.isFollowing
                                    }
                                } label: {
                                    Label("Follow", systemImage: "person.badge.plus")
                                }.tint(profileColor).buttonStyle(.borderedProminent).onAppear() {
                                    checkFollowing(name: userData.name, sessionName: session.name) { (result) in
                                        following = result
                                    }
                                }
                            }
                            if checkedFollowsYou {
                                if followsYou {
                                    Label("Follows you", systemImage: "checkmark")
                                } else {
                                    Label("Does not follow you", systemImage: "circle.slash")
                                }
                            } else {
                                ProgressView().onAppear() {
                                    checkFollowing(name: session.name, sessionName: userData.name) { (result) in
                                        followsYou = result
                                        checkedFollowsYou = true
                                    }
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                    }.padding([.top], navigationType == "stack" ? 105 : 60).background(.ultraThinMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()
        }
    }
}
public extension Date {
    func isBetween(_ startDate: Date, _ endDate: Date, includeBounds: Bool = false) -> Bool {
        if includeBounds {
            return startDate.compare(self).rawValue * compare(endDate).rawValue >= 0
        }
        return startDate.compare(self).rawValue * compare(endDate).rawValue > 0
    }
}
func checkFollowing(name: String, sessionName: String, callback: ((Bool) -> ())? = nil) {
    let url = URL(string: "https://api.wasteof.money/users/\(name)/followers/\(sessionName)")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "GET"
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
        } else {
            if let data = data {
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if str == "true" {
                            callback!(true)
                        } else {
                            callback!(false)
                        }
                    } else {
                        print("error")
                    }
                }
            }
        }
    }
    task.resume()
}
struct FollowResponse: Hashable, Codable {
    var ok: String
    var new: FollowResponseNew
}
struct FollowResponseNew: Hashable, Codable {
    var isFollowing: Bool
    var following: Int
    var followers: Int
}
func followUser(name: String, token: String, callback: ((FollowResponse) -> ())? = nil) {
    //var result: LoginResponse = LoginResponse(ok: "false", new: New(isLoving: false, loves: 0))
    let url = URL(string: "https://api.wasteof.money/users/\(name)/followers")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
        } else {
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let jsonData = dataString.data(using: .utf8)!
                var response: FollowResponse = FollowResponse(ok: "false", new: FollowResponseNew(isFollowing: false, following: 0, followers: 0))
                do {
                    response = try JSONDecoder().decode(FollowResponse.self, from: jsonData)
                    if response.ok == "unfollowed" || response.ok == "followed" {
                        callback!(response)
                    }
                } catch DecodingError.keyNotFound(_, _) {
                    print("something went wrong, key not found")
                    let str = String(decoding: jsonData, as: UTF8.self)
                    print("error: \(str)")
                } catch {
                    print("something went wrong")
                    print(jsonData)
                }
            }
        }
    }
    task.resume()
}
struct BioResponse: Hashable, Codable {
    var bio: String
    var ok: String
}
func updateBio(name: String, content: String, token: String, callback: ((BioResponse) -> ())? = nil) {
    let url = URL(string: "https://api.wasteof.money/users/\(name)/bio")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "PUT"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    struct BioType: Hashable, Codable {
        var bio: String
    }
    let body = BioType(bio: content)
    let finalBody = try? JSONEncoder().encode(body)
    request.httpBody = finalBody
    request.addValue(token, forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
        } else {
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let jsonData = dataString.data(using: .utf8)!
                var response: BioResponse = BioResponse(bio: "", ok: "false")
                do {
                    response = try JSONDecoder().decode(BioResponse.self, from: jsonData)
                    if response.ok == "updated bio" {
                        callback!(response)
                    }
                } catch DecodingError.keyNotFound(_, _) {
                    print("something went wrong, key not found")
                    let str = String(decoding: jsonData, as: UTF8.self)
                    print("error: \(str)")
                } catch {
                    print("something went wrong")
                    print(jsonData)
                }
            }
        }
    }
    task.resume()
}
func getUserPosts(name: String, page: Int, callback: ((UserFeed) -> ())? = nil) {
    guard let url = URL(string: "https://api.wasteof.money/users/\(name)/posts?page=\(page)") else {
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print("error with the data: \(error!)")
            return
        }
        do {
            let api = try JSONDecoder().decode(UserFeed.self, from:data)
            callback!(api)
        } catch {
            print("error decoding: \(error)")
        }
    }
    task.resume()
}
