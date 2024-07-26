//
//  WebViewModel.swift
//  MatoSwim
//
//  Created by Mac on 23/07/2024.
//

import WebKit
import SwiftSoup
import Foundation

class WebViewModel: NSObject, ObservableObject {
    private let webView: WKWebView
    @Published var waterTemperature: String?
    @Published var lastUpdated: String?
    @Published var temperatureThreshold: Double = 18.0 {
        didSet {
            UserDefaults.standard.set(temperatureThreshold, forKey: "temperatureThreshold")
        }
    }
    @Published var notificationsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    private var temperatureLog: [String] = []
    
    override init() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        
        // Initialize temperatureThreshold before calling super.init()
        self.temperatureThreshold = UserDefaults.standard.double(forKey: "temperatureThreshold")
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        super.init()
        
        // If there's no saved threshold, use the default value
        if self.temperatureThreshold == 0 {
            self.temperatureThreshold = 18.0
        }
        
        webView.navigationDelegate = self
        
        // Load temperature every 15 minutes in the background
        Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.checkTemperature()
        }
        
        // Load initial temperature
        fetchInitialTemperature()
    }
    
    private func fetchInitialTemperature() {
        // First, check for saved temperature from previous session
        if let savedTemp = UserDefaults.standard.string(forKey: "lastWaterTemperature") {
            DispatchQueue.main.async {
                self.waterTemperature = savedTemp
                if let savedTime = UserDefaults.standard.string(forKey: "lastUpdatedTime") {
                    self.lastUpdated = savedTime
                }
            }
        } else {
            // If no saved temperature, use JSON data
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
                                // Don't set lastUpdated here
                            }
                        }
                    }
                } catch {
                    print("Error reading or parsing matosinhos_water_temperatures.json: \(error)")
                }
            }
        }
        
        // After setting initial temperature, check for updates
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
                let temperatureDouble = Double(temperatureInt) / 10.0  // Changed to Double
                DispatchQueue.main.async {
                    let newTemperature = String(format: "%.1f", temperatureDouble)
                    // Only update if the new temperature is different
                    if newTemperature != self.waterTemperature {
                        self.waterTemperature = newTemperature
                        self.lastUpdated = self.getCurrentTime()
                        self.temperatureLog.append(newTemperature)
                        
                        // Save the new temperature to UserDefaults
                        UserDefaults.standard.set(newTemperature, forKey: "lastWaterTemperature")
                        UserDefaults.standard.set(self.lastUpdated, forKey: "lastUpdatedTime")
                        
                        print("New temperature: \(newTemperature) at \(Date())")
                        
                        // Check if temperature exceeds threshold
                        if temperatureDouble > self.temperatureThreshold {
                            self.sendNotification(temperature: temperatureDouble)
                        }
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
    
    private func sendNotification(temperature: Double) {
        guard notificationsEnabled else { return }
        NotificationManager.shared.sendNotification(temperature: temperature)
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
