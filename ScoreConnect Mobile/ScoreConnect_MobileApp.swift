//
//  ScoreConnect_MobileApp.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 11/6/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool {
        FirebaseApp.configure()
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

