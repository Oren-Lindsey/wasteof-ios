//
//  Login.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 11/25/23.
//

import SwiftUI

struct Login: View {
    // improve this before final launch
    @State var username = ""
    @State var password = ""
    @State var loadingSpinner = false
    @State var status = ""
    let regex = /^[a-z0-9_\\-]{1,20}$/
    var buttonDisabled: Bool {
        return username.isEmpty || password.isEmpty || (username.wholeMatch(of: regex) == nil)
    }
    @EnvironmentObject var session: Session
    @EnvironmentObject var loginProps: LoginProps
    func tryLogin() {
        loadingSpinner = true
        login(username: username.lowercased(), password: password, clear: true) { (isAuthenticated, token, username, password) in
            loadingSpinner = false
            if isAuthenticated {
                DispatchQueue.main.async {
                    session.name = username
                    session.token = token
                    loginProps.hasCredentials = true
                    loginProps.loggedIn = true
                    status = "Logged in successfully!"
                }
            } else {
                print("Error logging in! Full error: \"\(token)\"")
                status = "Error logging in! Full error: \"\(token)\""
            }
         }
    }
    var body: some View {
        VStack {
            header
            HStack {
                Spacer()
                VStack {
                    inputs
                    Text(status).foregroundStyle(.red)
                    Spacer()
                }
            }
            Spacer()
        }
        .ignoresSafeArea()
        
    }
    @ViewBuilder private var inputs: some View {
        VStack {
            Text("Login").font(.title2)
            TextField("Username", text: $username).textContentType(.username).padding(.horizontal, 10)
                .frame(height: 42)
                .overlay(
                  RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .stroke(username.wholeMatch(of: regex) != nil || !username.isEmpty ? Color.gray : Color.red, lineWidth: 1)
                ).autocapitalization(.none).textInputAutocapitalization(.never).textCase(.lowercase)
            SecureField("password", text: $password).textContentType(.password).padding(.horizontal, 10)
                .frame(height: 42)
                .overlay(
                  RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .stroke(password.isEmpty ? Color.red : Color.gray, lineWidth: 1)
                )
            button
        }.padding()
    }
    @ViewBuilder private var button: some View {
        if loadingSpinner {
            ProgressView()
        } else {
            Button {
                tryLogin()
            } label: {
                Text("Login")
            }.buttonStyle(.bordered).disabled(buttonDisabled)
        }
    }
    @ViewBuilder private var header: some View {
        VStack {
            VStack {
                Image("logoblack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                Text("wasteof.money for iOS [beta]").font(.system(.body, design: .monospaced))
            }.frame(width: 500, height: 150)
        }.frame(height: 250).background(
            LinearGradient(gradient: Gradient(colors: [.indigo, .green]), startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    Login()
}
