import SwiftUI
import Starscream
import FirebaseCore
import FirebaseAuth

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



    var body: some View {
        Text("ScoreConnect iOS")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
            .padding()
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Websocket connected: \(webSocketDelegate.isConnected ? "Yes" : "No")")
            
            Button("Switch to Scoreboard View") {
                            isScoreboardViewPresented.toggle()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .sheet(isPresented: $isScoreboardViewPresented) {
                            ScoreboardView(deviceData: webSocketDelegate.deviceDataManager.deviceData, socket: socket)
                                    }
            
            Button {
                sendTestMessage()
            } label: {
                Label("Test Test Message", systemImage: "arrow.up")
            }
            
            if webSocketDelegate.isConnected {
                Button {
                    getDeviceData()
                } label: {
                    Label("Refresh Data", systemImage: "arrow.clockwise")
                }
            } else {
                Button("Reconnect", systemImage: "exclamationmark.triangle") {
                    socket.connect()
                }
            }
            
            DeviceDataView(deviceData: webSocketDelegate.deviceDataManager.deviceData)
            
            
            Button("Toggle Websocket Logs", systemImage: "rectangle.dock") {
                self.showingWebsocketLogs.toggle()
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
            // handle = Auth.auth().addStateDidChangeListener { auth, user in }
            setupWebSocket()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if webSocketDelegate.isConnected {
                                getDeviceData()
                            }
                        }
        }
        .onDisappear {
            // Auth.auth().removeStateDidChangeListener(handle!)
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
