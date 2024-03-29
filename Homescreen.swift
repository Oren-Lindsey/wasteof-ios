//
//  Homescreen.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 11/25/23.
//

import SwiftUI
import AlertToast
class ExploreObject: ObservableObject {
    @Published var posts: [ExplorePostType]
    @Published var since: String
    init() {
            self.posts = []
            self.since = ""
        }
}
class ExploreType: Hashable, Codable {
    static func == (lhs: ExploreType, rhs: ExploreType) -> Bool {
        return lhs.posts == rhs.posts && lhs.since == rhs.since
    }
    var posts: [ExplorePostType]
    var since: String
    func hash(into hasher: inout Hasher) {
        hasher.combine(posts)
        hasher.combine(since)
    }
}
class ExplorePostType: Hashable, Codable {
    static func == (lhs: ExplorePostType, rhs: ExplorePostType) -> Bool {
        return lhs._id == rhs._id && lhs.content == rhs.content && lhs.time == rhs.time && rhs.__order == lhs.__order && lhs.comments == rhs.comments && lhs.loves == rhs.loves && lhs.reposts == rhs.reposts && lhs.poster == rhs.poster && lhs.revisions == rhs.revisions && lhs.edited == rhs.edited && lhs.repost == rhs.repost
    }
    let _id: String
    let content: String
    let time: Int
    let __order: Int
    let comments: Int
    let loves: Int
    let reposts: Int
    let poster: Poster
    let revisions: [Revision]
    let edited: Optional<Int>
    let repost: Optional<PostType>
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
        hasher.combine(content)
        hasher.combine(time)
        hasher.combine(__order)
        hasher.combine(comments)
        hasher.combine(loves)
        hasher.combine(reposts)
        hasher.combine(poster)
        hasher.combine(revisions)
        hasher.combine(edited)
        hasher.combine(repost)
    }
}
struct ExploreUser: Hashable, Codable {
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
}
class ExploreUsersObject: ObservableObject {
    @Published var users: [ExploreUser]
    init() {
            self.users = []
        }
}
func fetchFeed(user: String, page: Int, callback: ((FeedObject) -> ())? = nil) {
    guard let url = URL(string: "https://api.wasteof.money/users/\(user)/following/posts?page=\(page)") else {
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print("error with the data: \(error!)")
            return
        }
        do {
            let api = try JSONDecoder().decode(FeedType.self, from:data)
            let returnFeed = FeedObject()
            returnFeed.posts = api.posts
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
func fetchExplore(timeframe: String, callback: ((ExploreType) -> ())? = nil) {
    guard let url = URL(string: "https://api.wasteof.money/explore/posts/trending?timeframe=\(timeframe)") else {
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print(error!)
            return
        }
        do {
            let api = try JSONDecoder().decode(ExploreType.self, from:data)
            DispatchQueue.main.async {
                /*if add {
                    self?.feed.last = api.last
                    self?.feed.posts += api.posts
                } else {
                    self?.feed = api
                }*/
                callback!(api)
            }
        } catch {
            print(error)
            do {
                let apierror = try JSONDecoder().decode(ApiError.self, from:data)
                print(apierror.error)
            } catch {
                print(error)
                print(String(bytes: data, encoding: .utf8)!)
            }
        }
    }
    task.resume()
}
func fetchUsers(callback: (([ExploreUser]) -> ())? = nil) {
    //feed = FeedType(posts: [], last: false)
    guard let url = URL(string: "https://api.wasteof.money/explore/users/top") else {
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print(error!)
            return
        }
        do {
            let api = try JSONDecoder().decode([ExploreUser].self, from:data)
            DispatchQueue.main.async {
                callback!(api)
            }
        } catch {
            print(error)
            do {
                let apierror = try JSONDecoder().decode(ApiError.self, from:data)
                print(apierror.error)
            } catch {
                print(error)
                print(String(bytes: data, encoding: .utf8)!)
            }
        }
    }
    task.resume()
}
func fetchMessages(token: String, page: Int, read: Bool, callback: ((MessagesObject) -> ())? = nil) {
    guard let url = URL(string: "https://api.wasteof.money/messages/\(read ? "read" : "unread")?page=\(page)") else {
        return
    }
    let requestUrl = url
    var request = URLRequest(url: requestUrl)
    //var result: String = ""
    request.httpMethod = "GET"
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
            print("error with the data: \(error!)")
            return
        }
        do {
            let api = try JSONDecoder().decode(MessagesObject.self, from:data)
            DispatchQueue.main.async {
                callback!(api)
            }
        } catch {
            print("error decoding: \(error)")
            print(String(data:data, encoding:.utf8)!)
        }
    }
    //print("fetching")
    task.resume()
}
struct Homescreen: View {
    let defaults = UserDefaults.standard
    @State var newPostId = ""
    @State var showPopup = false
    @EnvironmentObject var session: Session
    @ObservedObject var feed: FeedObject = FeedObject()
    @ObservedObject var explore: ExploreObject = ExploreObject()
    @ObservedObject var exploreusers: ExploreUsersObject = ExploreUsersObject()
    @ObservedObject var messagesState: MessagesStateObject = MessagesStateObject()
    @State var page = 1
    @State var tabSelection = "feed"
    var body: some View {
        if feed.posts.count < 1 {
            ProgressView().onAppear {
                if let tab = UserDefaults.standard.object(forKey: "startup_tab") {
                    tabSelection = tab as! String
                } else {
                    defaults.set("feed", forKey: "startup_tab")
                }
                fetchFeed(user: session.name, page: page) { (feedObject) in
                    DispatchQueue.main.async {
                        feed.posts += feedObject.posts
                        feed.last = feedObject.last
                    }
                }
                fetchExplore(timeframe: "day") { exploreobject in
                    explore.posts = exploreobject.posts
                    explore.since = exploreobject.since
                }
                fetchUsers() { usersobject in
                    exploreusers.users = usersobject
                }
                fetchMessages(token: session.token, page: 1, read: false) { messages in
                    let messagesArray = messages.unread ?? []
                    if messagesArray.count > 0 {
                        messagesState.unread = messagesArray
                    }
                    messagesState.last = messages.last
                }
            }
        } else {
            ZStack {
                TabView(selection:$tabSelection) {
                    Feed(feed: feed, page: page).tabItem {
                        Label("Home", systemImage: "house")
                    }.environmentObject(session).tag("feed")
                    Explore(explore: explore, exploreusers: exploreusers).tabItem {
                        Label("Explore", systemImage: "globe")
                    }.environmentObject(session).tag("explore")
                    Messages(messagesState: messagesState, page: 1).environmentObject(session).tabItem {
                        Label("Messages", systemImage: "envelope")
                    }.badge(messagesState.unread.count).tag("messages")
                    User(name: session.name, navigationType: "tab").tabItem {
                        Label("Your Profile", systemImage: "person")
                    }.environmentObject(session).tag("profile")
                    Settings().tabItem {
                        Label("Settings", systemImage: "gear")
                    }.environmentObject(session).tag("settings")
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        PostEditor(newid: $newPostId, type: "main", reposts: 0, postId: nil, customColor: .accentColor).environmentObject(session)
                    }.padding().padding([.bottom],50)
                }.onChange(of: newPostId) {
                    showPopup.toggle()
                    fetchFeed(user: session.name, page: page) { (feedObject) in
                        DispatchQueue.main.async {
                            feed.posts = feedObject.posts
                            feed.last = feedObject.last
                        }
                    }
                }
            }.toast(isPresenting: $showPopup){
                AlertToast(displayMode: .hud, type: .systemImage("checkmark.bubble", .accentColor), title: "Posted!")
            }
        }
    }
}
