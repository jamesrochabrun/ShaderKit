//
//  RadiantHoloView.swift
//  ShaderKitDemo
//
//  Criss-cross diamond pattern with intense brightness
//

import SwiftUI
import ShaderKit

struct RadiantHoloView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .cyan
      ) {
        SimpleCardContent(
          title: "RADIANT HOLO",
          subtitle: "Radiant Rare",
          gradientColors: [
            Color(red: 0.15, green: 0.15, blue: 0.2),
            Color(red: 0.1, green: 0.1, blue: 0.15),
            Color(red: 0.18, green: 0.15, blue: 0.22)
          ]
        )
        .crisscrossHolo(intensity: 0.75)
      }
    }
    .navigationTitle("Radiant Holo")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    RadiantHoloView()
  }
}
