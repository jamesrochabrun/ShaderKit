//
//  CosmosHoloView.swift
//  ShaderKitDemo
//
//  Galaxy background with rainbow gradient overlay
//

import SwiftUI
import ShaderKit

struct CosmosHoloView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .purple
      ) {
        SimpleCardContent(
          title: "COSMOS HOLO",
          subtitle: "Galaxy Rare"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.05, green: 0.02, blue: 0.15),
                  Color(red: 0.02, green: 0.02, blue: 0.1),
                  Color(red: 0.08, green: 0.02, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .galaxyHolo(intensity: 0.8)
        }
      }
    }
    .navigationTitle("Cosmos Holo")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  NavigationStack {
    CosmosHoloView()
  }
}
