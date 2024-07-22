//
//  ContentView.swift
//  MatoSwim
//
//  Created by Mac on 22/07/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var seaTemperature: Double = 0.0

    var body: some View {
        VStack {
            Text("Matosinhos sea temperature")
                .font(.title)
                .padding()

            Text("\(seaTemperature, specifier: "%.1f")°C")
                .font(.system(size: 60))
                .fontWeight(.bold)

            Spacer()
        }
        .padding()
        .onAppear {
            fetchSeaTemperature()
        }
    }

    func fetchSeaTemperature() {
        guard let url = URL(string: "https://beachcam.meo.pt/livecams/praia-de-matosinhos/") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let html = String(data: data, encoding: .utf8) {
                if let startIndex = html.range(of: "Temp. do mar")?.upperBound,
                   let endIndex = html.range(of: "º", range: startIndex..<html.endIndex)?.lowerBound {
                    let temperatureString = String(html[startIndex..<endIndex])
                    if let temperature = Double(temperatureString) {
                        DispatchQueue.main.async {
                            seaTemperature = temperature
                        }
                    }
                }
            }
        }
        task.resume()
    }
}

#Preview {
    ContentView()
}
