//
//  TemperatureView.swift
//  MatoSwim
//
//  Created by Mac on 24/07/2024.
//

import SwiftUI

struct TemperatureView: View {
    @ObservedObject var webViewModel: WebViewModel
    
    var body: some View {
        VStack {
            Text("Matosinhos")
                .font(.title.bold())
                .padding(.top, 12)
            
            Text("water temperature")
                .font(.title)
                .fontWeight(.light)
                .padding(.bottom, 36)
            
            ZStack {
                WaterAnimationView()
                    .frame(height: 260)
                
                if let temperature = webViewModel.waterTemperature {
                    Text("\(temperature)°C")
                        .font(.system(size: 70))
                        .foregroundColor(Color.black.opacity(0.65))
                        .fontWeight(.bold)
                } else {
                    Text("N/A")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }
            
            HStack(alignment: .bottom, spacing: 12) {
                if let lastUpdated = webViewModel.lastUpdated {
                    Text("Last updated: \(lastUpdated)")
                        .font(.subheadline)
                        .padding(.top)
                }
                
                Button(action: {
                    webViewModel.checkTemperature()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.white)
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .onAppear {
            webViewModel.loadSavedTemperature()
            webViewModel.checkTemperature()
        }
        .preferredColorScheme(.dark)
    }
}
