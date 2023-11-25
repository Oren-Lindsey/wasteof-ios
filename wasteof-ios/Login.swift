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
    var buttonDisabled: Bool {
        return username.isEmpty || password.isEmpty // upgrade this to match this regex someday: /^[a-z0-9_\\-]{1,20}$/
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
                inputs
                Spacer()
            }
            Spacer()
        }
        .ignoresSafeArea()
        
    }
    @ViewBuilder private var inputs: some View {
        Form {
            Section {
                Text(status)
                HStack {
                    Spacer()
                    TextField("Username", text: $username).textContentType(.username)
                    Spacer()
                }
                HStack {
                    Spacer()
                    SecureField("Password", text: $password).textContentType(.password)
                    Spacer()
                }
            }
            Section {
                if loadingSpinner {
                    ProgressView()
                } else {
                    Button {
                        tryLogin()
                    } label: {
                        Text("Login")
                    }.buttonStyle(.bordered)
                }
            }.disabled(buttonDisabled)
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
