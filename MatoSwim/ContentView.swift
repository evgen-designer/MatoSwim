//
//  ContentView.swift
//  MatoSwim
//
//  Created by Mac on 22/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TemperatureView(webViewModel: webViewModel)
                    .tag(0)
                
                NotificationsView(webViewModel: webViewModel)
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
        .onAppear {
                    NotificationManager.shared.requestAuthorization()
                    clearBadge()
                }
    }
    
    private func clearBadge() {
            UNUserNotificationCenter.current().setBadgeCount(0) { error in
                if let error = error {
                    print("Error clearing badge: \(error)")
                }
            }
        }
}

#Preview {
    ContentView()
}
