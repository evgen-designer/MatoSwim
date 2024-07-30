//
//  WebViewModel.swift
//  MatoSwim
//
//  Created by Mac on 23/07/2024.
//

import WebKit
import SwiftSoup
import Foundation
import Combine

class WebViewModel: NSObject, ObservableObject {
    static let shared = WebViewModel()
        @Published var temperatureData: [String: Double] = [:]
    
    private let webView: WKWebView
    @Published var waterTemperature: String?
    @Published var lastUpdated: String?
    @Published var temperatureThreshold: Double = 18.0 {
        didSet {
            UserDefaults.standard.set(temperatureThreshold, forKey: "temperatureThreshold")
            checkAndScheduleNotification()
        }
    }
    @Published var notificationsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                checkAndScheduleNotification()
            } else {
                notificationWorkItem?.cancel()
            }
        }
    }
    private var temperatureLog: [String] = []
    private var notificationWorkItem: DispatchWorkItem?
    private var lastNotificationTime: Date?
    
    override init() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        
        self.temperatureThreshold = UserDefaults.standard.double(forKey: "temperatureThreshold")
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        super.init()
        
        if self.temperatureThreshold == 0 {
            self.temperatureThreshold = 18.0
        }
        
        webView.navigationDelegate = self
        
        Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.checkTemperature()
        }
        
        fetchInitialTemperature()
    }
    
    private func fetchInitialTemperature() {
        if let savedTemp = UserDefaults.standard.string(forKey: "lastWaterTemperature") {
            DispatchQueue.main.async {
                self.waterTemperature = savedTemp
                if let savedTime = UserDefaults.standard.string(forKey: "lastUpdatedTime") {
                    self.lastUpdated = savedTime
                }
            }
        } else {
            if let path = Bundle.main.path(forResource: "matosinhos_water_temperatures", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                       let temperatures = jsonResult["temperatures"] as? [String: Double] {
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd"
                        let currentDate = dateFormatter.string(from: Date())
                        
                        if let tempValue = temperatures[currentDate] {
                            let temperatureString = String(format: "%.1f", tempValue)
                            DispatchQueue.main.async {
                                self.waterTemperature = temperatureString
                            }
                        }
                    }
                } catch {
                    print("Error reading or parsing matosinhos_water_temperatures.json: \(error)")
                }
            }
        }
        
        checkTemperature()
    }
    
    func checkTemperature() {
        print("Checking temperature")
        guard let url = URL(string: "https://beachcam.meo.pt/livecams/praia-de-matosinhos/") else { return }
        webView.load(URLRequest(url: url))
    }
    
    private func parseHTML(_ html: String) {
        print("Received HTML content length: \(html.count)")
        
        do {
            let document: Document = try SwiftSoup.parse(html)
            let temperatureElement = try document.select("li.liveCamsHeader__infoList-item:contains(Temp. do mar) p").first()
            if let tempText = try temperatureElement?.text() {
                print("Found temperature text: \(tempText)")
                
                let temperatureInt = Int(tempText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
                let temperatureDouble = Double(temperatureInt) / 10.0
                DispatchQueue.main.async {
                    let newTemperature = String(format: "%.1f", temperatureDouble)
                    if newTemperature != self.waterTemperature {
                        self.waterTemperature = newTemperature
                        self.lastUpdated = self.getCurrentTime()
                        self.temperatureLog.append(newTemperature)
                        
                        UserDefaults.standard.set(newTemperature, forKey: "lastWaterTemperature")
                        UserDefaults.standard.set(self.lastUpdated, forKey: "lastUpdatedTime")
                        
                        print("New temperature: \(newTemperature) at \(Date())")
                        
                        self.checkAndScheduleNotification()
                    }
                }
            } else {
                print("Temperature element not found in HTML")
            }
        } catch {
            DispatchQueue.main.async {
                print("Error parsing HTML: \(error)")
            }
        }
    }
    
    private func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
    
    func loadSavedTemperature() {
        if let savedTemp = UserDefaults.standard.string(forKey: "lastWaterTemperature") {
            self.waterTemperature = savedTemp
        }
        if let savedTime = UserDefaults.standard.string(forKey: "lastUpdatedTime") {
            self.lastUpdated = savedTime
        }
    }
    
    func checkAndScheduleNotificationIfNeeded() {
            checkAndScheduleNotification()
        }
    
    private func checkAndScheduleNotification() {
        guard notificationsEnabled else { return }
        
        notificationWorkItem?.cancel()
        
        if let currentTemp = Double(waterTemperature ?? "0"), currentTemp >= temperatureThreshold {
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                
                if let currentTemp = Double(self.waterTemperature ?? "0"),
                   currentTemp >= self.temperatureThreshold,
                   self.notificationsEnabled {
                    
                    if let lastTime = self.lastNotificationTime,
                       Date().timeIntervalSince(lastTime) < 60 {
                        return
                    }
                    
                    NotificationManager.shared.sendNotification(temperature: currentTemp)
                    self.lastNotificationTime = Date()
                }
            }
            
            notificationWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: workItem)
        }
    }
}

extension WebViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerHTML") { [weak self] result, error in
            guard let html = result as? String, error == nil else {
                print("Failed to get HTML")
                return
            }
            self?.parseHTML(html)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Web view failed to load: \(error.localizedDescription)")
    }
}
