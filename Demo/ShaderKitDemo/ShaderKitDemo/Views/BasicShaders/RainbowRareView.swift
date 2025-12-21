//
//  RainbowRareView.swift
//  ShaderKitDemo
//
//  Glittery rainbow effect with luminosity blending
//

import SwiftUI
import ShaderKit

struct RainbowRareView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .pink
      ) {
        SimpleCardContent(
          title: "RAINBOW RARE",
          subtitle: "Secret Holo"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.3, green: 0.2, blue: 0.4),
                  Color(red: 0.25, green: 0.15, blue: 0.35),
                  Color(red: 0.35, green: 0.2, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .rainbowGlitter(intensity: 0.75)
        }
      }
    }
    .navigationTitle("Rainbow Rare")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    RainbowRareView()
  }
}
