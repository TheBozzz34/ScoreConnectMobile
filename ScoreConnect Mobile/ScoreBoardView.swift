//
//  ScoreBoardView.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 12/2/23.
//

import Foundation
import SwiftUI
import Starscream

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
                TeamScoreView(teamName: deviceData.teamAName, score: deviceData.teamAScore)
                Text("VS")
                    .font(.title)
                    .foregroundColor(.white)
                TeamScoreView(teamName: deviceData.teamBName, score: deviceData.teamBScore)
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
    
    var body: some View {
        VStack {
            Text(teamName)
                .font(.headline)
                .foregroundColor(.white)
            Text(score)
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}
