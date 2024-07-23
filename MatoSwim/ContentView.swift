//
//  ContentView.swift
//  MatoSwim
//
//  Created by Mac on 22/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel()
    @State private var showingThresholdAlert = false
    @State private var thresholdInput = ""
    
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
            
            // Only show "Last updated" if webViewModel.lastUpdated is not nil
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
            
            Button(action: {
                showingThresholdAlert = true
            }) {
                Text("Set Temperature Threshold")
            }
            .padding(.top)
        }
        .alert("Set Temperature Threshold", isPresented: $showingThresholdAlert) {
            TextField("Temperature", text: $thresholdInput)
                .keyboardType(.decimalPad)
            Button("OK") {
                if let threshold = Double(thresholdInput) {
                    webViewModel.temperatureThreshold = threshold
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the temperature threshold for notifications")
        }
        .onAppear {
            webViewModel.loadSavedTemperature()
            webViewModel.checkTemperature()
        }
    }
}

#Preview {
    ContentView()
}
