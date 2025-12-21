//
//  DiagonalHoloView.swift
//  ShaderKitDemo
//
//  Diagonal holographic effect with parallel lines
//

import SwiftUI
import ShaderKit

struct DiagonalHoloView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .orange
      ) {
        SimpleCardContent(
          title: "Diagonal Holo",
          subtitle: "Ultra Rare",
          image: "unicorn"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.2, green: 0.15, blue: 0.1),
                  Color(red: 0.15, green: 0.1, blue: 0.08),
                  Color(red: 0.25, green: 0.15, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .diagonalHolo(intensity: 0.7)
        }
      }
    }
    .navigationTitle("Diagonal Holo")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    DiagonalHoloView()
  }
}
