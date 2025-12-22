//
//  SpiralRingsView.swift
//  ShaderKitDemo
//
//  Golden spiral rings with holographic rainbow overlay
//

import SwiftUI
import ShaderKit

struct SpiralRingsView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .yellow
      ) {
        SimpleCardContent(
          title: "Spiral Rings",
          subtitle: "Golden Holo"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.35, green: 0.28, blue: 0.1),
                  Color(red: 0.25, green: 0.2, blue: 0.08),
                  Color(red: 0.3, green: 0.25, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .shader(.spiralRings())
        }
      }
    }
    .navigationTitle("Spiral Rings")
  }
}

#Preview {
  NavigationStack {
    SpiralRingsView()
  }
}
