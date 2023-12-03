import SwiftUI
import Starscream
import FirebaseCore
import FirebaseAuth

struct Library: Identifiable {
    let id = UUID()
    let name: String
    let version: String
    let description: String
    let url: String
}

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
    
    func isValidJSON(_ jsonString: String) -> Bool {
        if let data = jsonString.data(using: .utf8) {
            do {
                let _ = try JSONSerialization.jsonObject(with: data, options: [])
                return true
            } catch {
                return false
            }
        }
        return false
    }


    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        // Handle WebSocket events here
        switch event {
        case .connected(_):
            isConnected = true
            print("WebSocket is connected")
            // You can perform actions when the WebSocket is connected
        case .disconnected(_, _):
            isConnected = false
            print("WebSocket is disconnected")
            // You can handle reconnection logic if needed
        case .text(let string):
            print("Received message: \(string)")
            receivedMessages.append(string)
            
            do {
                let jsonData = Data(string.utf8)
                let decodedMessage = try JSONDecoder().decode(Message.self, from: jsonData)
                
                switch decodedMessage.type {
                case 18:
                    let textData = decodedMessage.text.data(using: .utf8) ?? Data()
                    if let receivedDeviceData = try? JSONDecoder().decode(DeviceData.self, from: textData) {
                        deviceDataManager.deviceData = receivedDeviceData
                        print("Setting Device Data")
                    } else {
                        print("Invalid device data")
                    }
                default:
                    break
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

struct ContentView: View {
    @StateObject private var webSocketDelegate = WebSocketDelegateWrapper()
    @State private var socket: WebSocket!
    @State private var showingWebsocketLogs = false
    @State private var isScoreboardViewPresented = false
    @State private var isShowingCredits = false
    // var handle: AuthStateDidChangeListenerHandle?
    
    let libraries: [Library] = [
        Library(name: "SwiftUI", version: "5.9.1", description: "Declarative UI framework by Apple", url: "https://www.swift.org/"),
        Library(name: "Starscream", version: "5.5.1", description: "Starscream is a conforming WebSocket (RFC 6455) library in Swift.", url: "https://github.com/daltoniam/Starscream"),
        Library(name: "FirebaseAnalytics", version: "10.18.0", description: "Firebase Analytics is a free, out-of-the-box analytics solution that inspires actionable insights based on app usage and user engagement.", url: "https://firebase.google.com"),
        Library(name: "FirebaseCore", version: "10.18.0", description: "Firebase is an app development platform with tools to help you build, grow and monetize your app", url: "firebase.google.com"),
        Library(name: "ExytePopupView", version: "2.8.3", description: "Toasts, alerts and popups library written with SwiftUI", url: "https://github.com/exyte/PopupView")
        ]

    
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
                
                Toggle("Show WebSocket Logs", isOn: $showingWebsocketLogs)


                Button("Switch to Scoreboard View") {
                    isScoreboardViewPresented.toggle()
                }
                .buttonStyle(RoundedButtonStyle())

                Button(action: sendTestMessage) {
                    Label("Test Test Message", systemImage: "arrow.up")
                }
                .buttonStyle(RoundedButtonStyle()) // Apply the custom button style

                // Other buttons and views...

                Button("Credits") {
                    isShowingCredits.toggle()
                }
                .buttonStyle(RoundedButtonStyle()) // Apply the custom button style
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
            // Handle onDisappear logic if needed
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
