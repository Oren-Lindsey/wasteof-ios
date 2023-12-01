//
//  Explore.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 12/1/23.
//

import SwiftUI

struct Explore: View {
    let timeframeOptions = ["day", "week", "month", "all"]
    @State private var selection = "day"
    @EnvironmentObject var session: Session
    @StateObject var explore: ExploreObject
    @StateObject var exploreusers: ExploreUsersObject
    var body: some View {
        NavigationStack {
            ScrollView {
                if (explore.posts.count < 1) {
                    ProgressView()
                } else {
                    HStack {
                        Text("Top Posts")
                            .padding([.horizontal])
                            .font(.title2)
                        Spacer()
                    }
                    ForEach(explore.posts.indices, id: \.self) { i in
                        let post = explore.posts[i]
                        NavigationLink {
                            Post(commentsState: CommentsObject(), _id: post._id, content: post.content, time: post.time, comments: post.comments, loves: post.loves, reposts: post.reposts, poster: post.poster, revisions: post.revisions, repost: post.repost)
                        } label: {
                            PostPreview(_id: post._id, content: post.content, time: post.time, comments: post.comments, loves: post.loves, reposts: post.reposts, poster: Poster(name: post.poster.name, id: post.poster.id, color: post.poster.color), revisions: post.revisions, edited: post.edited, repost: post.repost, navigation: true, recursion: 1).environmentObject(session).frame(minHeight: 100)
                        }
                    }.padding([.horizontal], 8)
                }
                
                if (exploreusers.users.count < 1) {
                    EmptyView()
                } else {
                    HStack {
                        Text("Top Users")
                            .padding([.horizontal])
                            .font(.title2)
                        Spacer()
                    }
                    let exploreusers = exploreusers
                    VStack {
                        ForEach(exploreusers.users.indices, id: \.self) { i in
                            if i == exploreusers.users.count - 1 {
                                UserPreview(name: exploreusers.users[i].name, id: exploreusers.users[i].id, bio: exploreusers.users[i].bio, verified: exploreusers.users[i].verified, beta: exploreusers.users[i].beta, permissions: exploreusers.users[i].permissions, links: exploreusers.users[i].links, history: exploreusers.users[i].history, stats: exploreusers.users[i].stats, color: exploreusers.users[i].color)
                                    .padding([.bottom], 96)
                            } else {
                                UserPreview(name: exploreusers.users[i].name, id: exploreusers.users[i].id, bio: exploreusers.users[i].bio, verified: exploreusers.users[i].verified, beta: exploreusers.users[i].beta, permissions: exploreusers.users[i].permissions, links: exploreusers.users[i].links, history: exploreusers.users[i].history, stats: exploreusers.users[i].stats, color: exploreusers.users[i].color)//.padding([.horizontal], 16)
                            }
                        }
                    }.padding([.horizontal], 8)
                }
            }/*.onAppear {
                fetchExplore(timeframe: selection) { exploreobject in
                    explore.posts = exploreobject.posts
                    explore.since = exploreobject.since
                }
                fetchUsers() { users in
                    exploreusers.users = users
                }
            }*/.ignoresSafeArea(.all, edges: [.bottom, .horizontal]).refreshable {
                fetchExplore(timeframe: selection) { exploreobject in
                    explore.posts = exploreobject.posts
                    explore.since = exploreobject.since
                }
                fetchUsers() { users in
                    exploreusers.users = users
                }
            }.navigationTitle("Explore").toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        
                        Picker("Select a timeframe", selection: $selection) {
                            ForEach(timeframeOptions, id: \.self) {
                                /*Text($0)
                                 }*/
                                Text($0)
                            }
                        }
                        //}
                    } label: {
                        Label("Sort", systemImage: "line.3.horizontal.decrease.circle.fill")
                    }.onChange(of: selection) {
                        fetchExplore(timeframe: selection) { exploreobject in
                            explore.posts = exploreobject.posts
                            explore.since = exploreobject.since
                        }
                    }
                }
            }
        }
    }
}
