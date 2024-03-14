//
//  Settings.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 3/12/24.
//

import SwiftUI
import Foundation
extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
enum AppIconProvider {
    static func appIcon(in bundle: Bundle = .main) -> String {
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last else {
            fatalError("Could not find icons in bundle")
        }

        return iconFileName
    }
}
struct Settings: View {
    @EnvironmentObject var session: Session
    @State var tabSelection = "feed"
    let defaults = UserDefaults.standard
    var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("App Icon")) {
                        NavigationLink {
                            iconChooser.navigationTitle("Choose Icon")
                        } label: {
                            Text("Choose Icon")
                        }
                    }
                    Section(header: Text("Startup")) {
                        Picker("Startup Tab", selection: $tabSelection) {
                            Text("Feed").tag("feed")
                            Text("Explore").tag("explore")
                            Text("Messages").tag("messages")
                        }.onChange(of: tabSelection) {
                            defaults.set(tabSelection, forKey: "startup_tab")
                        }.onAppear {
                            if let tab = UserDefaults.standard.object(forKey: "startup_tab") {
                                tabSelection = tab as! String
                            } else {
                                defaults.set("feed", forKey: "startup_tab")
                            }
                        }
                    }
                    Section(header:Text("Session")) {
                        Button {
                            session.token = ""
                            session.name = ""
                            session.color = "indigo"
                            session.bio = ""
                            session.verified = false
                            session.permissions = Permissions(admin: false, banned: false)
                            session.beta = false
                            session.color = ""
                            session.links = []
                            session.history = History(joined: 0)
                            session.stats = UserStats(followers: 0, following: 0, posts: 0)
                            session.online = false
                            session.token = ""
                            [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity].forEach {
                                let status = SecItemDelete([kSecClass: $0,kSecAttrSynchronizable: kSecAttrSynchronizableAny] as CFDictionary)
                                if status != errSecSuccess && status != errSecItemNotFound {
                                    print(status)
                                }
                            }
                        } label: {
                            Label("Log Out", systemImage: "trash")
                        }
                    }
                    Section {
                        NavigationLink {
                            About(appIcon: AppIconProvider.appIcon()).environmentObject(session).navigationTitle("About")
                        } label: {
                            Text("About")
                        }
                    }
                }.navigationTitle("Settings")
            }
        }
    @ViewBuilder private var iconChooser: some View {
        List {
            Button {
                changeAppIcon(to: "AppIcon")
            } label: {
                Text("Original")
            }
            Button {
                changeAppIcon(to: "IndigoIcon")
            } label: {
                Text("Indigo")
            }
            Button {
                changeAppIcon(to: "CenteredIcon")
            } label: {
                Text("Centered")
            }
            Button {
                changeAppIcon(to: "CenteredIndigo")
            } label: {
                Text("Centered Indigo")
            }
        }
    }
    private func changeAppIcon(to iconName: String) {
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Error setting alternate icon \(error.localizedDescription)")
            }
        }
    }
}
