//
//  NotificationsView.swift
//  MatoSwim
//
//  Created by Mac on 26/07/2024.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject var webViewModel: WebViewModel
    
    var body: some View {
        VStack {
            Text("Notify change")
                .font(.title)
                .padding(.top, 12)
            
            Text("of water temperature")
                .font(.title)
                .padding(.bottom, 16)
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable notifications", isOn: $webViewModel.notificationsEnabled)
                    
                    if webViewModel.notificationsEnabled {
                        Picker("Temperature level", selection: $webViewModel.temperatureThreshold) {
                            ForEach(120...220, id: \.self) { value in
                                Text(String(format: "%.1f°C", Double(value) / 10)).tag(Double(value) / 10)
                            }
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
