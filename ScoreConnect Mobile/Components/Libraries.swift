//
//  Libraries.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 12/3/23.
//

import Foundation
import SwiftUI

struct Library: Identifiable {
    let id = UUID()
    let name: String
    let version: String
    let description: String
    let url: String
}

struct Libraries: View {
    let libraries: [Library] = [
        Library(name: "SwiftUI", version: "5.9.1", description: "Declarative UI framework by Apple", url: "https://www.swift.org/"),
        Library(name: "Starscream", version: "4.0.6", description: "Starscream is a conforming WebSocket (RFC 6455) library in Swift.", url: "https://github.com/daltoniam/Starscream"),
        Library(name: "FirebaseAnalytics", version: "10.18.0", description: "Firebase Analytics is a free, out-of-the-box analytics solution that inspires actionable insights based on app usage and user engagement.", url: "https://firebase.google.com"),
        Library(name: "FirebaseCore", version: "10.18.0", description: "Firebase is an app development platform with tools to help you build, grow and monetize your app", url: "firebase.google.com"),
        Library(name: "ExytePopupView", version: "2.8.3", description: "Toasts, alerts and popups library written with SwiftUI", url: "https://github.com/exyte/PopupView"),
        Library(name: "GoogleSignIn", version: "7.0.0", description: "Get users into your apps quickly and securely, using a registration system they already use and trust—their Google account.", url: "https://github.com/google/GoogleSignIn-iOS")
        ]
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
                    Image("yorha-no-2-type-b-1")
                        .resizable()
                        .frame(width: 100.0, height: 100.0)
                        .cornerRadius(50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.gray, lineWidth: 5)
                        )
                    
                    Text("Credits")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Text("Created by Necrozma")
                        .font(.headline)
                        .foregroundColor(.gray)
            
                    Text("Using Xcode and CocoaPods")
                        .font(.caption)
                        .foregroundColor(.gray)
                        
                    List(libraries) { library in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(library.name)
                                    .font(.headline)
                                Spacer()
                                Link(destination: URL(string: library.url)!) {
                                    Image(systemName: "link.circle.fill")
                                        .foregroundColor(.blue)
                                    }
                                }
                            Text("Version: \(library.version)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(library.description)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                        
                    
                    Spacer()
                }
                .padding()
    }
}
