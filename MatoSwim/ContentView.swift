//
//  ContentView.swift
//  MatoSwim
//
//  Created by Mac on 22/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TemperatureViewSection(webViewModel: webViewModel)
                    .tag(0)
                
                NotificationViewSection(webViewModel: webViewModel)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            VStack {
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(.white.opacity(0.15))
                
                CustomTabView(selectedTab: $selectedTab)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CustomTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 30) {
            TabItem(title: "Temperature", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabItem(title: "Notifications", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.vertical, 10)
        .background(Color.black.edgesIgnoringSafeArea(.bottom))
    }
}

struct TabItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                    .padding(.bottom, 4)
                
                if isSelected {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 1)
                        .matchedGeometryEffect(id: "underline", in: namespace)
                } else {
                    Color.clear.frame(height: 3)
                }
            }
        }
    }
    
    @Namespace private var namespace
}

struct TemperatureViewSection: View {
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
                TemperatureView()
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

struct NotificationViewSection: View {
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

#Preview {
    ContentView()
}
