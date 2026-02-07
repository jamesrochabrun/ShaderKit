//
//  HalftonePastelView.swift
//  ShaderKitDemo
//
//  Demo for the halftone pastel holographic shader effect
//

import SwiftUI
import ShaderKit

struct HalftonePastelView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .purple
      ) {
        SimpleCardContent(
          title: "Halftone Pastel",
          subtitle: "Secret Rare",
          image: "unicorn"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.85, green: 0.8, blue: 0.95),
                  Color(red: 0.8, green: 0.9, blue: 0.95),
                  Color(red: 0.95, green: 0.85, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .halftonePastel(intensity: 0.85)
        }
      }
    }
    .navigationTitle("Halftone Pastel")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    HalftonePastelView()
  }
}
