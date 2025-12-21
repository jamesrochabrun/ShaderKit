//
//  ShinyRareView.swift
//  ShaderKitDemo
//
//  Metallic sun-pillar effect with crosshatch texture
//

import SwiftUI
import ShaderKit

struct ShinyRareView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .white
      ) {
        SimpleCardContent(
          title: "SHINY RARE",
          subtitle: "Ultra Metallic"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.2, green: 0.2, blue: 0.22),
                  Color(red: 0.15, green: 0.15, blue: 0.18),
                  Color(red: 0.22, green: 0.2, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .metallicCrosshatch(intensity: 0.75)
        }
      }
    }
    .navigationTitle("Shiny Rare")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    ShinyRareView()
  }
}
