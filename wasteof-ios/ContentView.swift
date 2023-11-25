//
//  ContentView.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 11/25/23.
//

import SwiftUI
@MainActor class Session: ObservableObject {
    @Published var name: String = ""
    @Published var id: String = ""
    @Published var bio: String = ""
    @Published var verified: Bool = false
    @Published var permissions: Permissions = Permissions(admin: false, banned: false)
    @Published var beta: Bool = false
    @Published var color: String = ""
    @Published var links: [Link] = []
    @Published var history: History = History(joined: 0)
    @Published var stats: UserStats = UserStats(followers: 0, following: 0, posts: 0)
    @Published var online: Bool = false
    @Published var token: String = ""
}
@MainActor class LoginProps: ObservableObject {
    @Published var hasCredentials: Bool = false
    @Published var loggedIn: Bool = false
}
class FeedType: Hashable, Codable {
    static func == (lhs: FeedType, rhs: FeedType) -> Bool {
        return lhs.posts == rhs.posts && lhs.last == rhs.last
    }
    
    var posts: [PostType]
    var last: Bool
    init() {
        self.posts = []
        self.last = true
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(posts)
        hasher.combine(last)
    }
}
class FeedObject: ObservableObject {
    @Published var posts: [PostType]
    @Published var last: Bool
    init() {
            self.posts = []
            self.last = true
        }
}
struct Credentials {
    var username: String
    var password: String
    static let server = "wasteof.money"
}
struct UserDecoder: Hashable, Codable {
    var name: String
    var id: String
    var bio: String
    var verified: Bool
    var permissions: Permissions
    var beta: Bool
    var color: String
    var links: [Link]
    var history: History
    var stats: UserStats
    var online: Bool
}
struct ExploreStats: Hashable, Codable {
    let followers: Int
}
enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
func login(username: String, password: String, clear: Bool, callback: ((Bool, String, String, String) -> ())? = nil) {
    var result: String = ""
    let url = URL(string: "https://api.wasteof.money/session")
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    struct BodyData: Codable {
        let username: String
        let password: String
    }
    let body = BodyData(username: username, password: password)
    let finalBody = try? JSONEncoder().encode(body)
    request.httpBody = finalBody
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
            result = error.localizedDescription
            callback!(false, result, username, password)
        } else {
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                struct LoginResponse: Decodable {
                    let token: String
                }
                let jsonData = dataString.data(using: .utf8)!
                var response: LoginResponse = LoginResponse(token: "")
                do {
                    response = try JSONDecoder().decode(LoginResponse.self, from: jsonData)
                } catch DecodingError.keyNotFound(_, _) {
                    if dataString.contains("cloudflare") {
                        callback!(false, "wasteof.money is down, try again later", username, password)
                    } else {
                        callback!(false, "Username or password incorrect", username, password)
                    }
                } catch {
                    callback!(false, error.localizedDescription, username, password)
                }
                result = response.token
                if result.count < 1 {
                    if dataString.contains("cloudflare") {
                        callback!(false, "wasteof.money is down, try again later", username, password)
                    } else {
                        callback!(false, "Username or password incorrect", username, password)
                    }
                } else {
                    do {
                        try savePassword(username: username, password: password, clear: clear)
                        callback!(true, result, username, password)
                    } catch KeychainError.unhandledError(let status) {
                        print("Keychain Error, status is: \(status)")
                        callback!(false, "Could not save password to keychain.", username, password)
                    } catch {
                        callback!(false, "Something went wrong...", username, password)
                    }
                }
                
                //return data
            }
        }
    }
    task.resume()
}
func savePassword(username: String, password: String, clear: Bool) throws {
    if clear {
        [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity].forEach {
            let status = SecItemDelete([
                kSecClass: $0,
                kSecAttrSynchronizable: kSecAttrSynchronizableAny
            ] as CFDictionary)
            if status != errSecSuccess && status != errSecItemNotFound {
            }
        }
    }
    let credentials: Credentials = Credentials(username: username, password: password)
    let account = credentials.username
    let password = credentials.password.data(using: String.Encoding.utf8)!
    let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,kSecAttrAccount as String: account,kSecAttrServer as String: Credentials.server,kSecValueData as String: password]
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    print("Saved successfully!")
}
func lookupToken() throws -> Credentials {
    let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword, kSecAttrServer as String: Credentials.server,kSecMatchLimit as String: kSecMatchLimitOne,kSecReturnAttributes as String: true,kSecReturnData as String: true]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    guard let existingItem = item as? [String : Any],
        let passwordData = existingItem[kSecValueData as String] as? Data,
        let password = String(data: passwordData, encoding: String.Encoding.utf8),
        let account = existingItem[kSecAttrAccount as String] as? String
    else {
        throw KeychainError.unexpectedPasswordData
    }
                let credentials = Credentials(username: account, password: password)
    return credentials
}
func getUserData(username: String, callback: ((UserDecoder) -> ())? = nil) {
    guard let url = URL(string: "https://api.wasteof.money/users/\(username)") else {
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print("error with the data: \(error!)")
            return
        }
        do {
            let api = try JSONDecoder().decode(UserDecoder.self, from:data)
            callback!(api)
        } catch {
            print("error decoding: \(error)")
        }
    }
    task.resume()
}
struct ContentView: View {
    @State var checked = false
    @StateObject var loginProps: LoginProps = LoginProps()
    @ObservedObject var session: Session = Session()
    @ObservedObject var feed: FeedObject = FeedObject()
    var body: some View {
        if checked {
            if session.name != "" && session.token != "" && loginProps.loggedIn && loginProps.hasCredentials {
                if session.color == "" {
                    ProgressView()
                        .padding().onAppear {
                            getUserData(username: session.name) { (user) in
                                DispatchQueue.main.async {
                                    session.stats = user.stats
                                    session.beta = user.beta
                                    session.online = user.online
                                    session.color = user.color
                                    session.history = user.history
                                    session.id = user.id
                                    session.links = user.links
                                    session.permissions = user.permissions
                                    session.verified = user.verified
                                    session.bio = user.bio
                                }
                            }
                        }
                } else {
                    UserPreview(name: session.name, id: session.id, bio: session.bio, verified: session.verified, beta: session.beta, permissions: session.permissions, links: session.links, history: session.history, stats: ExploreStats(followers: session.stats.followers), color: session.color)
                }
            } else {
                Login().environmentObject(session).environmentObject(loginProps)
            }
        } else {
            LaunchScreen().onAppear {
                /*[kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity].forEach {
                    let status = SecItemDelete([
                        kSecClass: $0,
                        kSecAttrSynchronizable: kSecAttrSynchronizableAny
                    ] as CFDictionary)
                    if status != errSecSuccess && status != errSecItemNotFound {
                        // no error handling lol
                    }
                } //clear all keychain*/
                var credentials = Credentials(username: "", password: "")
                do {
                    credentials = try lookupToken()
                } catch {
                    credentials = Credentials(username: "", password: "")
                }
                if credentials.username != "" {
                    loginProps.hasCredentials = true
                    session.name = credentials.username
                    login(username: credentials.username, password: credentials.password, clear: true) { (isAuthenticated, token, username, password) in
                        if isAuthenticated {
                            DispatchQueue.main.async {
                                session.token = token
                                loginProps.loggedIn = true
                                checked = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                loginProps.loggedIn = false
                                checked = true
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        loginProps.hasCredentials = false
                        checked = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
