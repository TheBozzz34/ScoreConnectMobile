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
    func application(_ application: UIApplication, open url: URL, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        // return GIDSignIn.sharedInstance.handle(url)
        return true
    }
}

@main
struct ScoreConnect_MobileApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView();
        }
    }
}

