//
//  PolishedAluminumView.swift
//  ShaderKitDemo
//
//  Polished aluminum card with diagonal rainbow reflection
//

import SwiftUI
import ShaderKit

struct PolishedAluminumView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .gray
      ) {
        SimpleCardContent(
          title: "ALUMINUM",
          subtitle: "Holographic Metal"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.75, green: 0.77, blue: 0.80),
                  Color(red: 0.65, green: 0.67, blue: 0.70),
                  Color(red: 0.70, green: 0.72, blue: 0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .shader(.polishedAluminum(intensity: 0.85))
        }
      }
    }
    .navigationTitle("Polished Aluminum")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    PolishedAluminumView()
  }
}
