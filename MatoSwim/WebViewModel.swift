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
    private var temperatureLog: [String] = []
    
    override init() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        webView.navigationDelegate = self
        
        // Load temperature every 15 minutes in the background
        Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.checkTemperature()
        }

        // Load initial temperature from JSON file
        fetchInitialTemperature()
    }
    
    private func fetchInitialTemperature() {
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
    
    func checkTemperature() {
        guard let url = URL(string: "https://beachcam.meo.pt/livecams/praia-de-matosinhos/") else { return }
        webView.load(URLRequest(url: url))
    }
    
    private func parseHTML(_ html: String) {
        do {
            let document: Document = try SwiftSoup.parse(html)
            let temperatureElement = try document.select("li.liveCamsHeader__infoList-item:contains(Temp. do mar) p").first()
            if let tempText = try temperatureElement?.text() {
                let temperatureInt = Int(tempText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
                let temperatureFloat = Float(temperatureInt) / 10.0
                DispatchQueue.main.async {
                    let newTemperature = String(format: "%.1f", temperatureFloat)
                    // Only update if the new temperature is different
                    if newTemperature != self.waterTemperature {
                        self.waterTemperature = newTemperature
                        self.lastUpdated = self.getCurrentTime()
                        self.temperatureLog.append(newTemperature)
                    }
                }
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
}
