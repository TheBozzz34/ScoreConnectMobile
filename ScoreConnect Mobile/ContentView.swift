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


struct ContentView: View {
    @StateObject private var webSocketDelegate = WebSocketDelegateWrapper()
    @State private var socket: WebSocket!
    @State private var showingWebsocketLogs = false
    @State private var isScoreboardViewPresented = false
    @State private var isShowingCredits = false
    // var handle: AuthStateDidChangeListenerHandle?

    
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
            
            Button("Send Test Analytics Event") {
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                  AnalyticsParameterItemID: "test",
                  AnalyticsParameterItemName: "test",
                  AnalyticsParameterContentType: "cont",
                ])


            }
            .padding()

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
            setupWebSocket()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if webSocketDelegate.isConnected {
                    getDeviceData()
                }
            }
        }
        .onDisappear {
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
