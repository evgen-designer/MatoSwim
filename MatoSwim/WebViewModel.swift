//
//  WebViewModel.swift
//  MatoSwim
//
//  Created by Mac on 23/07/2024.
//

import WebKit
import SwiftSoup

class WebViewModel: NSObject, ObservableObject {
    private let webView: WKWebView
    @Published var waterTemperature: String?

    override init() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        webView.navigationDelegate = self
    }

    func loadWebsite() {
        guard let url = URL(string: "https://beachcam.meo.pt/livecams/praia-de-matosinhos/") else { return }
        webView.load(URLRequest(url: url))
    }

    private func parseHTML(_ html: String) {
        do {
            let document: Document = try SwiftSoup.parse(html)
            let temperatureElement = try document.select("div.liveCamsDetailAside__weather-col-inside p").first()
            if let tempText = try temperatureElement?.text() {
                let temperature = tempText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                DispatchQueue.main.async {
                    self.waterTemperature = temperature
                }
            }
        } catch {
            print("Error parsing HTML: \(error)")
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
}
