//
//  WallCommentEditor.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 1/9/24.
//

import SwiftUI

struct WallCommentButton: View {
    var onPost = {}
    @EnvironmentObject var session: Session
    @State var html = ""
    @State var editor = false
    let type: String
    let username: String
    let parent: Optional<String>
    let color: Color
    /*var color: Color {
        switch session.color {
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
    }*/
    var body: some View {
        Button {
            editor = true
        } label: {
            if type == "comment" {
                HStack {
                    Image(systemName: "text.bubble")
                    Text("New Comment")
                }
            } else if type == "reply" {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                    Text("Reply")
                }
            } else {
                VStack {
                    Image(systemName: "text.bubble")
                    Text("\(type)")
                }.tint(color).buttonStyle(.bordered)
            }
        }.buttonStyle(.bordered).tint(color).popover(isPresented: $editor, arrowEdge: .top) {
            VStack {
                HStack {
                    Button() {
                        editor.toggle()
                    } label: {
                        Text("Cancel").padding(3)
                    }.tint(color)
                    Spacer()
                    Button {
                        postWallComment(wallUser: username, token: session.token, content: html, parent: parent) { (response) in
                            onPost()
                        }
                        editor = false
                    } label: {
                        HStack {
                            Text("Post")
                            Image(systemName: "arrow.up.circle.fill")
                        }.padding(3)
                    }.tint(color)
                }
                WallCommentEditor(currenthtml: $html)
            }.padding(5)
            
        }.padding(5)
    }
    func onPost(_ callback: @escaping () -> ()) -> some View {
        WallCommentButton(onPost: callback, type: type, username: username, parent: parent, color: color)
        }
}
struct CommentResponse: Codable {
    let ok: String
    let id: String
}
func postWallComment(wallUser: String, token: String, content: String, parent: Optional<String>, callback: ((CommentResponse) -> ())? = nil) {
    let url = URL(string: "https://api.wasteof.money/users/\(wallUser)/wall")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    struct BodyData: Codable {
        let content: String
        let parent: Optional<String>
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    let body = BodyData(content: content, parent: parent)
    let finalBody = try? JSONEncoder().encode(body)
    request.httpBody = finalBody
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
        } else {
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let jsonData = dataString.data(using: .utf8)!
                var response: CommentResponse = CommentResponse(ok: "no", id: "")
                do {
                    response = try JSONDecoder().decode(CommentResponse.self, from: jsonData)
                    if response.ok == "made comment" {
                        callback!(response)
                    }
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

