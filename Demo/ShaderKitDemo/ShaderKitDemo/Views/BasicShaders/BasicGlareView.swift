//
//  BasicGlareView.swift
//  ShaderKitDemo
//
//  Simple radial glare effect following tilt position
//

import SwiftUI
import ShaderKit

struct BasicGlareView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      HolographicCardContainer(
        width: 260,
        height: 380,
        shadowColor: .white
      ) {
        SimpleCardContent(
          title: "BASIC GLARE",
          subtitle: "Common Card"
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.95, green: 0.9, blue: 0.8),
                  Color(red: 0.9, green: 0.85, blue: 0.75),
                  Color(red: 0.85, green: 0.8, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .simpleGlare(intensity: 0.8)
        }
      }
    }
    .navigationTitle("Basic Glare")
  }
}

#Preview {
  NavigationStack {
    BasicGlareView()
  }
}
