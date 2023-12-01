//
//  Feed.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 11/26/23.
//

import SwiftUI

struct Feed: View {
    @EnvironmentObject var session: Session
    @StateObject var feed: FeedObject
    @State var page: Int
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(feed.posts.indices, id: \.self) { i in
                    let post = feed.posts[i]
                    NavigationLink {
                        Post(commentsState: CommentsObject(), _id: post._id, content: post.content, time: post.time, comments: post.comments, loves: post.loves, reposts: post.reposts, poster: post.poster, revisions: post.revisions, repost: post.repost)
                    } label: {
                        PostPreview(_id: post._id, content: post.content, time: post.time, comments: post.comments, loves: post.loves, reposts: post.reposts, poster: post.poster, revisions: post.revisions, edited: post.edited, repost: post.repost, navigation: true, recursion: 0).environmentObject(session)
                    }.background(.regularMaterial,in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                if !feed.last {
                    Button {
                        page += 1
                        fetchFeed(user: session.name, page: page) { (feedobject) in
                            DispatchQueue.main.async {
                                feed.posts += feedobject.posts
                                feed.last = feedobject.last
                            }
                        }
                    } label: {
                        Label("Show more", systemImage: "rectangle.stack.badge.plus")
                    }.buttonStyle(.bordered)
                }
            }.padding([.horizontal], 5).navigationTitle("@\(session.name)'s Feed").refreshable {
                fetchFeed(user: session.name, page: 1) { feedobject in
                    DispatchQueue.main.async {
                        feed.posts = feedobject.posts
                        feed.last = feedobject.last
                    }
                }
            }
        }
    }
}

#Preview {
    Feed(feed: FeedObject(), page: 1)
}
