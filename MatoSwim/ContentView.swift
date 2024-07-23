//
//  ContentView.swift
//  MatoSwim
//
//  Created by Mac on 22/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel()
    
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
