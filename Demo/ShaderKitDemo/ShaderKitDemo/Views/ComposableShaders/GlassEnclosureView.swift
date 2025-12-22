//
//  GlassEnclosureView.swift
//  ShaderKitDemo
//
//  Glass enclosure effect demo - card behind curved reflective glass
//

import SwiftUI
import ShaderKit

struct GlassEnclosureView: View {
  var body: some View {
    ZStack {
      // Dark gradient background to show off reflections
      LinearGradient(
        colors: [
          Color(red: 0.08, green: 0.08, blue: 0.12),
          Color(red: 0.05, green: 0.05, blue: 0.08)
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()

      HolographicCardContainer(
        width: 280,
        height: 400,
        shadowColor: .white.opacity(0.3)
      ) {
        SimpleCardContent(
          title: "Glass Effect",
          subtitle: "Reflective Glass"
        ) {
          // Rich gradient background to show glass reflections
          ZStack {
            LinearGradient(
              colors: [
                Color(red: 0.15, green: 0.2, blue: 0.35),
                Color(red: 0.1, green: 0.12, blue: 0.25),
                Color(red: 0.08, green: 0.1, blue: 0.2)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )

            // Subtle pattern overlay
            RadialGradient(
              colors: [
                Color.white.opacity(0.05),
                Color.clear
              ],
              center: .topLeading,
              startRadius: 0,
              endRadius: 400
            )
          }
        }
        .shader(.glassEnclosure())
      }
    }
    .navigationTitle("Glass Enclosure")
  }
}

#Preview {
  NavigationStack {
    GlassEnclosureView()
  }
}
