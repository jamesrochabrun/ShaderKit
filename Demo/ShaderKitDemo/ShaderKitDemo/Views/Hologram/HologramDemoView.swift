//
//  HologramDemoView.swift
//  ShaderKitDemo
//
//  Demo view showcasing holographic card collection
//

import SwiftUI
import ShaderKit

struct HologramDemoView: View {
  @State private var selectedCard = 0
  
  var body: some View {
    ZStack {
      // Background
      LinearGradient(
        colors: [
          Color(red: 0.05, green: 0.05, blue: 0.1),
          Color(red: 0.1, green: 0.08, blue: 0.15)
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()
      
      VStack(spacing: 40) {
        Text("Collection")
          .font(.title)
          .fontWeight(.bold)
          .foregroundStyle(.white)
        
        // Card display
        TabView(selection: $selectedCard) {
          CardOneView()
            .tag(0)
          
          CardTwoView()
            .tag(1)
          
          CardThreeView()
            .tag(2)
          
          CardFourView()
            .tag(3)
          
          CardFiveView()
            .tag(4)
          
          CardSixView()
            .tag(5)
        }
#if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
#endif
        .frame(height: 500)
        
#if os(iOS)
        Text("Tilt your device to see the effect")
          .font(.caption)
          .foregroundStyle(.white.opacity(0.6))
#else
        Text("Drag on cards to see the effect")
          .font(.caption)
          .foregroundStyle(.white.opacity(0.6))
#endif
      }
      .padding()
    }
    .navigationTitle("Hologram Cards")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  HologramDemoView()
}
