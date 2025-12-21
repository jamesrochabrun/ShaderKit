//
//  PokemonVView.swift
//  ShaderKitDemo
//
//  Diagonal holographic effect with parallel lines
//

import SwiftUI
import ShaderKit

struct PokemonVView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .orange
      ) {
        SimpleCardContent(
          title: "POKEMON V",
          subtitle: "Ultra Rare",
          image: "puppy",
          gradientColors: [
            Color(red: 0.2, green: 0.15, blue: 0.1),
            Color(red: 0.15, green: 0.1, blue: 0.08),
            Color(red: 0.25, green: 0.15, blue: 0.1)
          ]
        )
        .diagonalHolo(intensity: 0.7)
      }
    }
    .navigationTitle("Pokemon V")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    PokemonVView()
  }
}
