//
//  WebSocketDelegateWrapper.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 12/3/23.
//

import Foundation
import SwiftUI
import Starscream

struct DeviceData: Codable {
    let deviceID: String
    let deviceName: String
    let deviceType: String
    let deviceStatus: String
    let deviceData: String
    let deviceCommands: String
    let teamAName: String
    let teamBName: String
    let teamAScore: String
    let teamBScore: String
}

struct Message: Codable {
    let id: Int
    let type: Int
    let text: String
}

class DeviceDataManager: ObservableObject {
    @Published var deviceData: DeviceData
    
    init(deviceData: DeviceData) {
            self.deviceData = deviceData
        }
}

class WebSocketDelegateWrapper: ObservableObject, WebSocketDelegate {
    @Published var isConnected = false
    @Published var receivedMessages: [String] = []
    @Published var deviceDataManager = DeviceDataManager(deviceData: DeviceData(deviceID: "", deviceName: "", deviceType: "", deviceStatus: "", deviceData: "", deviceCommands: "", teamAName: "", teamBName: "", teamAScore: "", teamBScore: ""))
    
    func prettyPrintMessage(_ message: Message) -> String? {
        guard let jsonData = message.text.data(using: .utf8) else {
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            
            if let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                return prettyPrintedString
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }



    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        // Handle WebSocket events here
        switch event {
        case .connected(_):
            isConnected = true
            print("WebSocket is connected")
        case .disconnected(_, _):
            isConnected = false
            print("WebSocket is disconnected")
        case .text(let string):
            do {
                let jsonData = Data(string.utf8)
                let decodedMessage = try JSONDecoder().decode(Message.self, from: jsonData)
            
                
                switch decodedMessage.type {
                case 18:
                    let textData = decodedMessage.text.data(using: .utf8) ?? Data()
                    if let receivedDeviceData = try? JSONDecoder().decode(DeviceData.self, from: textData) {
                        deviceDataManager.deviceData = receivedDeviceData
                        print("Received message: \(prettyPrintMessage(decodedMessage) ?? "Unknown Message ")")
                        receivedMessages.append(prettyPrintMessage(decodedMessage) ?? "Unknown Message ")
                    } else {
                        print("Invalid device data")
                    }
                default:
                    print("Received message: \(decodedMessage.text)")
                    receivedMessages.append("Received message: \(decodedMessage.text)")
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        case .error(let error):
            isConnected = false
            if let errorMessage = error?.localizedDescription {
                    let fullErrorMessage = "Error occurred: \(errorMessage)"
                    receivedMessages.append(fullErrorMessage) // Append error message to the array
                    print(fullErrorMessage)
                } else {
                    let defaultErrorMessage = "An error occurred, but no additional information is available."
                    receivedMessages.append(defaultErrorMessage) // Append default error message
                    print(defaultErrorMessage)
                }
        default:
            break
        }
    }
}
