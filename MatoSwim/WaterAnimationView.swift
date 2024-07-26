//
//  WaterAnimationView.swift
//  MatoSwim
//
//  Created by Mac on 26/07/2024.
//

import SwiftUI

struct WaterAnimationView: View {
    @State var startAnimation: CGFloat = 0
    let maskSize = CGSize(width: 122, height: 400)
    @State var maxHeight: CGFloat = 420
    
    var body: some View {
            GeometryReader { proxy in
                let size = proxy.size
                
                ZStack {
                    // Tube
                    ZStack {
                        RoundedRectangle(cornerRadius: 40)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [
                                    Color(.systemGray6),
                                    Color.white,
                                ]), startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 308, height: 308)
                            .mask(RoundedRectangle(cornerRadius: 40))
                            .opacity(0.8)
                        
                        WaterWaveS(progress: 0.9, waveHeight: 0.04, offset: startAnimation + 190)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [
                                    Color.mint,
                                    Color.blue,
                                ]), startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 308, height: 308)
                            .mask(RoundedRectangle(cornerRadius: 40))
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color(red: 236/255, green: 234/255, blue: 235/255),
                                            lineWidth: 1)
                                    .shadow(color: Color.black.opacity(0.7), radius: 10, x: 0, y: 0)
                                    .clipShape(RoundedRectangle(cornerRadius: 40))
                            )
                        
                        WaterWaveS(progress: 0.9, waveHeight: 0.04, offset: startAnimation)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [
                                    Color.mint,
                                    Color.blue,
                                ]), startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 308, height: 308)
                            .mask(RoundedRectangle(cornerRadius: 40))
                            .opacity(0.5)
                        
                        RoundedRectangle(cornerRadius: 40)
                            .strokeBorder(
                                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5), Color(red: 0.93, green: 0.94, blue: 0.97, opacity: 1)]), startPoint: .top, endPoint: .bottom),
                                lineWidth: 6
                            )
                            .frame(width: 308, height: 308)
                    }
                    .frame(width: size.width, height: size.height, alignment: .center)
                    .onAppear {
                        // Looping animation
                        withAnimation(.linear(duration: 0.7).repeatForever(autoreverses: false)) {
                            // loop will not finish if startAnimation will be larger than rect width
                            startAnimation = size.width
                        }
                    }
                }
            }
    }
}

struct WaterWaveS: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat
    var offset: CGFloat

    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .zero)
            
            let progressHeight: CGFloat = (1 - progress) * rect.height
            let height = waveHeight * rect.height
            
            for value in stride(from: 0, through: rect.width, by: 1) {
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees: value + offset).radians)
                let y: CGFloat = progressHeight + (height * sine)
                
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}

#Preview {
    WaterAnimationView()
        .preferredColorScheme(.dark)
}
