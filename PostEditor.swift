//
//  PostEditor.swift
//  wasteof.money
//
//  Created by Oren Lindsey on 11/24/23.
//

import SwiftUI
import MarkupEditor
struct PostEditor: View, MarkupDelegate {
    func markupInput(_ view: MarkupWKWebView) {
        MarkupEditor.selectedWebView?.getHtml { html in
            currenthtml = html!
        }
    }
    @EnvironmentObject var session: Session
    @State var showingEditor = false
    @State var startHtml = ""
    @State var currenthtml = ""
    @Binding var newid: String
    var type: String
    var reposts: Int
    var postId: Optional<String>
    var customColor: Color
    var profileColor: Color {
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
    }
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
    var normalButton: Bool {
        return type == "main"
    }
    var body: some View {
        if type == "main" {
            Button {
                showingEditor.toggle()
            } label: {
                Text("+").frame(width: 50, height: 50)
            }.popover(isPresented: $showingEditor) {
                editor
            }.buttonStyle(.borderedProminent).clipShape(Circle())
        } else if type == "repost" {
            Button {
                showingEditor.toggle()
            } label: {
                VStack {
                    Image(systemName: "repeat")
                    Text("\(reposts)")
                }
            }.popover(isPresented: $showingEditor) {
                editor
            }.tint(customColor).buttonStyle(.bordered)
        }
    }
    @ViewBuilder private var editor: some View {
        VStack {
            HStack {
                Button() {
                    showingEditor.toggle()
                } label: {
                    Text("Cancel").padding(3)
                }.tint(profileColor)
                Spacer()
                Button {
                    post(token: session.token, content: currenthtml, repost: postId) { (id) in
                        newid = id
                        showingEditor.toggle()
                    }
                } label: {
                    HStack {
                        Text("Post")
                        Image(systemName: "arrow.up.circle.fill")
                    }.padding(3)
                }.tint(profileColor)
            }
            MarkupEditorView(markupDelegate: self, html: $startHtml)
        }.padding(5)
    }
    func post(token: String, content: String, repost: Optional<String>, callback: ((String) -> ())? = nil) {
        let url = URL(string: "https://api.wasteof.money/posts/")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        struct BodyData: Codable {
            let post: String
            let repost: Optional<String>?
        }
        struct PostResponse: Codable {
            let ok: String
            let id: String
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let body = BodyData(post: content, repost: repost)
        let finalBody = try? JSONEncoder().encode(body)
        request.httpBody = finalBody
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                //result = LoginResponse(ok: "error.localizedDescription", new: New(isLoving: false, loves: 0))
            } else {
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    let jsonData = dataString.data(using: .utf8)!
                    var response: PostResponse = PostResponse(ok: "no", id: "")
                    //print(response)
                    do {
                        response = try JSONDecoder().decode(PostResponse.self, from: jsonData)
                        if response.ok == "made post" {
                            callback!(response.id)
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
}

/*#Preview {
    PostEditor()
}*/
