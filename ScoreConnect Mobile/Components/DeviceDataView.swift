//
//  WebSocketDelegateWrapper.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 12/2/23.
//

import SwiftUI

struct DeviceDataView: View {
    let deviceData: DeviceData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            dataRow(title: "Device ID", value: deviceData.deviceID)
            dataRow(title: "Device Name", value: deviceData.deviceName)
            dataRow(title: "Device Type", value: deviceData.deviceType)
            dataRow(title: "Device Status", value: deviceData.deviceStatus)
            dataRow(title: "Device Data", value: deviceData.deviceData)
            dataRow(title: "Device Commands", value: deviceData.deviceCommands)
            dataRow(title: "Team A Name", value: deviceData.teamAName)
            dataRow(title: "Team B Name", value: deviceData.teamBName)
            dataRow(title: "Team A Score", value: "\(deviceData.teamAScore)")
            dataRow(title: "Team B Score", value: "\(deviceData.teamBScore)")
        }
        .padding()
    }
    
    @ViewBuilder
    private func dataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 150, alignment: .leading)
            Text(value)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
    }
}
