//
//  AppDelegate.swift
//  MatoSwim
//
//  Created by Mac on 23/07/2024.
//

import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print("Handling background URL session: \(identifier)")
        completionHandler()
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        print("Background refresh started")
        scheduleAppRefresh()
        
        let webViewModel = WebViewModel()
        webViewModel.checkTemperature()
        
        task.expirationHandler = {
            print("Background task expired")
            task.setTaskCompleted(success: false)
        }
        
        // Wait for the temperature check to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            print("Background refresh completed")
            task.setTaskCompleted(success: true)
        }
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.matoswim.fetchTemperature")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch every 15 minutes
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
