//
//  Types.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 11/25/23.
//

import Foundation
class PostType: Hashable, Codable, Equatable {
    var _id: String
    var content: String
    var time: Int
    var comments: Int
    var loves: Int
    var reposts: Int
    var poster: Poster
    var revisions: [Revision]
    var edited: Optional<Int>
    var repost: Optional<PostType>
    init() {
        self._id = ""
        self.content = ""
        self.time = 0
        self.comments = 0
        self.loves = 0
        self.reposts = 0
        self.poster = Poster(name: "", id: "", color: "")
        self.revisions = []
        self.edited = nil
        self.repost = nil
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
        hasher.combine(content)
        hasher.combine(time)
        hasher.combine(comments)
        hasher.combine(loves)
        hasher.combine(reposts)
        hasher.combine(poster)
        hasher.combine(revisions)
        hasher.combine(edited)
        hasher.combine(repost)
    }
    static func ==(lhs: PostType, rhs: PostType) -> Bool {
        return lhs._id == rhs._id && lhs.content == rhs.content && lhs.time == rhs.time && lhs.comments == rhs.comments && lhs.loves == rhs.loves && lhs.reposts == rhs.reposts && lhs.revisions == rhs.revisions && lhs.edited == rhs.edited && lhs.repost == rhs.repost
    }
}
struct Revision: Hashable, Codable {
    let content: String
    let time: Int
    let current: Optional<Bool>
    let editor: Optional<String>
}
struct Poster: Hashable, Codable {
    let name: String
    let id: String
    let color: String
}
struct Link: Hashable, Codable {
    let label: String
    let url: String
}
struct History: Hashable, Codable {
    let joined: Int
}
struct UserStats: Hashable, Codable {
    var followers: Int
    var following: Int
    var posts: Int
}
struct Permissions: Hashable, Codable {
    let admin: Bool
    let banned: Bool
}
