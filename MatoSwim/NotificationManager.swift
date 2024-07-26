//
//  NotificationManager.swift
//  MatoSwim
//
//  Created by Mac on 26/07/2024.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    func sendNotification(temperature: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Water Temperature Alert"
        content.body = "The water temperature in Matosinhos is now \(String(format: "%.1f", temperature))°C!"
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }
}
