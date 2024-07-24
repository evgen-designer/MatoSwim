//
//  MatoSwimApp.swift
//  MatoSwim
//
//  Created by Mac on 22/07/2024.
//

import SwiftUI

@main
struct MatoSwimApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            print("Notification permission granted")
                        } else if let error = error {
                            print("Error requesting notification permission: \(error)")
                        }
                    }
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                appDelegate.scheduleAppRefresh()
            }
        }
    }
}
