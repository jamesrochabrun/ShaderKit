//
//  ReverseHoloView.swift
//  ShaderKitDemo
//
//  Inverted foil effect with shine overlay
//

import SwiftUI
import ShaderKit

struct ReverseHoloView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .green
      ) {
        SimpleCardContent(
          title: "REVERSE HOLO",
          subtitle: "Non-Rare Holo",
          image: "unicorn"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.2, green: 0.1, blue: 0.3),
                  Color(red: 0.1, green: 0.1, blue: 0.2),
                  Color(red: 0.15, green: 0.05, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .invertedFoil(intensity: 0.7)
        }
      }
    }
    .navigationTitle("Reverse Holo")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    ReverseHoloView()
  }
}
