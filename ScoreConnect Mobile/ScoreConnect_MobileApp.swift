//
//  ScoreConnect_MobileApp.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 11/6/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            FirebaseApp.configure()
            return true
        }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            return GIDSignIn.sharedInstance.handle(url)
        }
}

@main
struct ScoreConnect_MobileApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appUser: GIDGoogleUser?

    
    var body: some Scene {
        WindowGroup {
            ContentView(appUser: appUser)
                .onAppear() {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if error == nil {
                            print("No user")
                        } else {
                            appUser = user!               
                        }
                    }
                }
        }
    }
}

