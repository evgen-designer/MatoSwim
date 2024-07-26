//
//  CustomTabView.swift
//  MatoSwim
//
//  Created by Mac on 26/07/2024.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 30) {
            TabItem(title: "Temperature", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabItem(title: "Notifications", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.vertical, 10)
        .background(Color.black.edgesIgnoringSafeArea(.bottom))
    }
}

struct TabItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                    .padding(.bottom, 4)
                
                if isSelected {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 1)
                        .matchedGeometryEffect(id: "underline", in: namespace)
                } else {
                    Color.clear.frame(height: 3)
                }
            }
        }
    }
    
    @Namespace private var namespace
}

#Preview {
    CustomTabView(selectedTab: .constant(0))
}
