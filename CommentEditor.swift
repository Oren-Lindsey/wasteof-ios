//
//  CommentEditor.swift
//  wasteof.money
//
//  Created by Oren Lindsey on 10/27/23.
//

import SwiftUI
import MarkupEditor
struct CommentEditor: View, MarkupDelegate {
    //let color: Color
    @EnvironmentObject var session: Session
    let id: String
    let color: Color
    let parent: Optional<String>
    let poster: Optional<CommentPoster>
    let type: String
    @State var currenthtml: String = ""
    @State private var startHtml: String = ""
    @State var editor = false
    //@State private var startHtml: String = "<p>helloworld</p>"
    /*init() {
        MarkupEditor.style = .labeled
        let myToolbarContents = ToolbarContents(
            correction: true, formatContents: FormatContents(subSuper: false)
        )
        ToolbarContents.custom = myToolbarContents
        MarkupEditor.selectedWebView?.getHtml { html in
            print(html!)
        }
        print("ran")
    }*/
    func markupInput(_ view: MarkupWKWebView) {
        MarkupEditor.selectedWebView?.getHtml { html in
            currenthtml = html!
        }
    }
    var body: some View {
        //ScrollView {
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
                        postComment(_id: id, token: session.token, content: currenthtml, parent: parent)
                        editor = false
                    } label: {
                        HStack {
                            Text("Post")
                            Image(systemName: "arrow.up.circle.fill")
                        }.padding(3)
                    }.tint(color)
                }
                MarkupEditorView(markupDelegate: self, html: $startHtml)
            }.padding(5)
            /*VStack {
             HStack {
             Button(role:.destructive) {
             editor = false
             } label: {
             Text("Cancel").padding(3)
             }
             Spacer()
             Text("New Comment")
             .padding(3)
             .font(.title2)
             Spacer()
             Button {
             print("a")
             } label: {
             Text("Post")
             .padding(3)
             }
             }
             Text("Edit:")
             .font(.title3)
             MarkupEditorView(markupDelegate: self, html: $startHtml)*/
        }.padding(5)//id: _id).environmentObject(session)
    }
    /*@ViewBuilder var editorView: some View {
        @State var startHtml = "<p> </p>"
        VStack {
            HStack {
                Button(role:.destructive) {
                    
                } label: {
                    Text("Cancel").padding(3)
                }
                Spacer()
                Text("New Comment")
                    .padding(3)
                    .font(.title2)
                Spacer()
                Button {
                    postComment(_id: id ?? "", token: token ?? "", content: currenthtml, parent: nil)
                } label: {
                    Text("Post")
                        .padding(3)
                }
            }
            Text("Edit:")
                .font(.title3)
            MarkupEditorView(markupDelegate: self, html: $startHtml)
        }.padding(5)
    }*/
    func postComment(_id: String, token: String, content: String, parent: Optional<String>) {
        print(content)
        //var result: LoginResponse = LoginResponse(ok: "false", new: New(isLoving: false, loves: 0))
        let url = URL(string: "https://api.wasteof.money/posts/\(_id)/comments")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        struct BodyData: Codable {
            // Define your data model here.
            // This struct should conform to Codable if you want to send it in the request body.
            let content: String
            let parent: Optional<String>?
        }
        struct CommentResponse: Codable {
            // Define your data model here.
            // This struct should conform to Codable if you want to send it in the request body.
            let ok: String
            let id: String
        }
        //let postString = "username=\(username)&password=\(password)"
        /*struct LoginData: Hashable, Codable {
            let username: String
            let password: String
        }*/
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let body = BodyData(content: content, parent: parent)
        let finalBody = try? JSONEncoder().encode(body)
        request.httpBody = finalBody
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                //result = LoginResponse(ok: "error.localizedDescription", new: New(isLoving: false, loves: 0))
            } else {
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    let jsonData = dataString.data(using: .utf8)!
                    var response: CommentResponse = CommentResponse(ok: "no", id: "")
                    //print(response)
                    do {
                        response = try JSONDecoder().decode(CommentResponse.self, from: jsonData)
                        if response.ok == "made comment" {
                            print(response.id)
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

