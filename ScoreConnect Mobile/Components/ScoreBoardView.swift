//
//  ScoreBoardView.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 12/2/23.
//

import Foundation
import SwiftUI
import Starscream
import ExytePopupView


struct ScoreboardView: View {
    let deviceData: DeviceData
    let socket: WebSocket

    init(deviceData: DeviceData, socket: WebSocket) {
            self.deviceData = deviceData 
            self.socket = socket
        }
    
    func writeData(type: Int, text: String) {
        let messageJson: [String: Any] = [
            "type": type,
            "message": text,
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
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 40) {
                TeamScoreView(teamName: deviceData.teamAName, score: deviceData.teamAScore, socket: socket)
                Text("VS")
                    .font(.title)
                    .foregroundColor(.white)
                TeamScoreView(teamName: deviceData.teamBName, score: deviceData.teamBScore, socket: socket)
            }
            
            HStack(spacing: 30) {
                Button(action: {
                    writeData(type: 5, text: "teamAPlus1")
                }) {
                    Text("+1")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    writeData(type: 5, text: "teamAPlus3")
                }) {
                    Text("+3")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    writeData(type: 5, text: "teamBPlus1")
                }) {
                    Text("+1")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    writeData(type: 5, text: "teamBPlus3")
                }) {
                    Text("+3")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray)
        .edgesIgnoringSafeArea(.all)
    }
}

struct TeamScoreView: View {
    let teamName: String
    let score: String
    let socket: WebSocket
    @State var showingPopup = false
    @State private var newTeamName: String = ""
    @State private var keyboardHeight: CGFloat = 0
    
    func editTeamName() {
        showingPopup = true
    }
    
    var body: some View {
        VStack {
            Button(teamName, systemImage: "square.and.pencil", action: editTeamName)
                .font(.headline)
                .foregroundColor(.white)
            Text(score)
                .font(.largeTitle)
                .foregroundColor(.white)
                .popup(isPresented: $showingPopup) {
                    HStack(alignment: .top, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Edit Team Name")
                                        .font(.system(size: 16, weight: .bold))
                                    TextField("New Team Name", text: $newTeamName)
                                                    .padding()
                                                    .background(Color.gray.opacity(0.2))
                                                    .cornerRadius(8)
                                                    .padding(.horizontal)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Button {
                                        self.showingPopup = false
                                        
                                    } label: {
                                        Text("Save")
                                            // .frame(width: 112, height: 40)
                                    }
                                    .cornerRadius(8)
                                }
                            }
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 24, leading: 16, bottom: 42, trailing: 16))
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .padding(.bottom, keyboardHeight) // Add padding to move content up when keyboard is shown
                            .offset(y: -keyboardHeight) // Move the popup to the top of the keyboard
                            .animation(.easeInOut, value: showingPopup)



                        } customize: {
                            $0
                                .isOpaque(true)
                                .type (.toast)
                                .dragToDismiss(true)
                                .closeOnTap(false)
                                .closeOnTapOutside(true)
                        }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = keyboardRect.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            self.keyboardHeight = 0
        }
    }
}
