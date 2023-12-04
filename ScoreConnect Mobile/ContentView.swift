//
//  ConentView.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 11/6/23.
//

import SwiftUI
import Starscream
import FirebaseCore
import Foundation
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn

struct ContentView: View {
    @StateObject private var webSocketDelegate = WebSocketDelegateWrapper()
    @State private var socket: WebSocket!
    @State private var showingWebsocketLogs = false
    @State private var isScoreboardViewPresented = false
    @State private var isShowingCredits = false
    @State private var isShowingGoogleLogin = false
    @State private var handle: AuthStateDidChangeListenerHandle?
    @StateObject var profileImageViewModel = ProfileImageViewModel()
    var appUser: GIDGoogleUser?
    
    func sendTestMessage() {
        let testJson: [String: Any] = [
            "type": 1,
            "message": "test",
            "id": Int.random(in: 1..<10000)
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: testJson, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socket.write(string: jsonString)
            } else {
                print("Error converting JSON data to string.")
            }
        } catch {
            print("Error creating JSON data: \(error)")
        }
    }
    
    func getDeviceData() {
        let messageJson: [String: Any] = [
            "type": 8,
            "message": "test",
            "id": Int.random(in: 1..<10000)
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messageJson, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socket.write(string: jsonString)
            } else {
                print("Error converting JSON data to string.")
            }
        } catch {
            print("Error creating JSON data: \(error)")
        }
    }
    
    func printDeviceData() {
        print("Device Data: \(webSocketDelegate.deviceDataManager.deviceData)")
    }
    
    func connectWs() {
        socket.connect()
    }

    var body: some View {
        VStack {
            if let displayName = Auth.auth().currentUser?.displayName {
                if let image = profileImageViewModel.profileImage {
                                Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .offset(x: UIScreen.main.bounds.width - 250, y: -5)
                            } else {
                                Text("Loading profile image...")
                                    .onAppear {
                                        profileImageViewModel.fetchImage()
                                    }
                            }
                            Text("Hello, \(displayName)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding()
                        } else {
                            Text("Hello, Guest")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding()
                        }
            Text("ScoreConnect iOS")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.blue) // Adjust color to match the style

                Text("Websocket connected: \(webSocketDelegate.isConnected ? "Yes" : "No")")
                
                Toggle("Show WebSocket Logs", isOn: $showingWebsocketLogs).toggleStyle(.button)
                
                if !webSocketDelegate.isConnected {
                    Button(action: connectWs) {
                        Label("Reconnect", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                }

                Button("Switch to Scoreboard View") {
                    isScoreboardViewPresented.toggle()
                }
                .sheet(isPresented: $isScoreboardViewPresented) {
                                            ScoreboardView(deviceData: webSocketDelegate.deviceDataManager.deviceData, socket: socket)
                                                    }
                .buttonStyle(RoundedButtonStyle())

                Button(action: sendTestMessage) {
                    Label("Test Test Message", systemImage: "arrow.up")
                }
                }
                .buttonStyle(RoundedButtonStyle()) // Apply the custom button style

                .sheet(isPresented: $isShowingCredits) {
                              Libraries()
                }
        
            
            if Auth.auth().currentUser?.uid != nil {
                Button("Logout") {
                    do {
                      try Auth.auth().signOut()
                    } catch let signOutError as NSError {
                      print("Error signing out: %@", signOutError)
                    }
                }
            } else {
                 Button("Login") {
                     isShowingGoogleLogin = true
                 }.sheet(isPresented: $isShowingGoogleLogin, content: {
                     NavigationView {
                                 GoogleSignInViewController()
                                     .edgesIgnoringSafeArea(.all)
                                     .navigationBarTitle("Google Sign In")
                             }
                     
                 })
                 .padding()
            }

            if showingWebsocketLogs {
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(webSocketDelegate.receivedMessages.indices, id: \.self) { index in
                            let message = webSocketDelegate.receivedMessages[index]
                            Text(message)
                                .foregroundColor(message.contains("Error occurred") ? .red : .primary)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            
            Button("Credits") {
                isShowingCredits.toggle()
            }
            .buttonStyle(RoundedButtonStyle())
        }
        .onAppear {
            handle = Auth.auth().addStateDidChangeListener { auth, user in
            }
    
            setupWebSocket()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if webSocketDelegate.isConnected {
                    getDeviceData()
                }
            }
        }
        .onDisappear {
            Auth.auth().removeStateDidChangeListener(handle!)
        }
    }

    // Define a custom button style for consistent appearance
    struct RoundedButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }


    private func setupWebSocket() {
        guard let url = URL(string: "wss://wss.catgirlsaresexy.org") else {
            print("Invalid WebSocket URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5 // Set a timeout interval if needed

        socket = WebSocket(request: request)
        socket.delegate = webSocketDelegate
        socket.connect()
    }
}
