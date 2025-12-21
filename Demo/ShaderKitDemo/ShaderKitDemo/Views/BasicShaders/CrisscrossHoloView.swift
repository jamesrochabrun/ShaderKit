//
//  CrisscrossHoloView.swift
//  ShaderKitDemo
//
//  Criss-cross diagonal rainbow pattern
//

import SwiftUI
import ShaderKit

struct CrisscrossHoloView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .cyan
      ) {
        SimpleCardContent(
          title: "CRISSCROSS",
          subtitle: "Diamond Rare",
          image: "unicorn"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.15, green: 0.15, blue: 0.2),
                  Color(red: 0.1, green: 0.1, blue: 0.15),
                  Color(red: 0.18, green: 0.15, blue: 0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .crisscrossHolo(intensity: 0.75)
        }
      }
    }
    .navigationTitle("Crisscross Holo")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    CrisscrossHoloView()
  }
}
