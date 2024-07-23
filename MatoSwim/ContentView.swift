//
//  ContentView.swift
//  MatoSwim
//
//  Created by Mac on 22/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel()
    @State private var isEditing = false
    @State private var thresholdInput = "18.0"
    
    var body: some View {
        VStack {
            Text("Water temperature in Matosinhos")
                .font(.title)
                .padding()
            
            if let temperature = webViewModel.waterTemperature {
                Text("\(temperature)°C")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            } else {
                Text("N/A")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            if let lastUpdated = webViewModel.lastUpdated {
                Text("Last updated: \(lastUpdated)")
                    .font(.subheadline)
                    .padding(.top)
            }
            
            Button(action: {
                webViewModel.checkTemperature()
            }) {
                Text("Refresh")
            }
            .padding(.top)
            
            Section(header: Text("Temperature change notification").font(.headline)) {
                Toggle("Enable notifications", isOn: $webViewModel.notificationsEnabled)
                    .padding(.vertical)
                
                HStack {
                    if isEditing {
                        TextField("", text: $thresholdInput)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: thresholdInput) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered.contains(".") {
                                    let parts = filtered.split(separator: ".")
                                    if parts.count > 1 {
                                        let whole = parts[0].prefix(2)
                                        let fraction = parts[1].prefix(1)
                                        thresholdInput = "\(whole).\(fraction)"
                                    } else {
                                        thresholdInput = filtered
                                    }
                                } else if filtered.count > 2 {
                                    thresholdInput = "\(filtered.prefix(2)).\(filtered.dropFirst(2).prefix(1))"
                                } else {
                                    thresholdInput = filtered
                                }
                            }
                    } else {
                        Text(thresholdInput)
                            .frame(width: 80, alignment: .trailing)
                            .opacity(webViewModel.notificationsEnabled ? 1.0 : 0.4)
                    }
                    
                    Text("°C")
                        .opacity(webViewModel.notificationsEnabled ? 1.0 : 0.4)
                    
                    Button(action: {
                        if isEditing {
                            if let threshold = Double(thresholdInput) {
                                webViewModel.temperatureThreshold = threshold
                            }
                        }
                        isEditing.toggle()
                    }) {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil")
                    }
                    .opacity(webViewModel.notificationsEnabled ? 1.0 : 0.4)
                }
                .disabled(!webViewModel.notificationsEnabled)
            }
            .padding()
        }
        .onAppear {
            webViewModel.loadSavedTemperature()
            webViewModel.checkTemperature()
            thresholdInput = String(format: "%.1f", webViewModel.temperatureThreshold)
        }
    }
}

#Preview {
    ContentView()
}
