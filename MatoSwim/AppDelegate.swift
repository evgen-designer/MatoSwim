//
//  AppDelegate.swift
//  MatoSwim
//
//  Created by Mac on 23/07/2024.
//

import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.fetchTemperature", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // Handle background URL session events if needed
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let webViewModel = WebViewModel()
        webViewModel.checkTemperature()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            task.setTaskCompleted(success: true)
        }
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourapp.fetchTemperature")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch every 15 minutes
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
