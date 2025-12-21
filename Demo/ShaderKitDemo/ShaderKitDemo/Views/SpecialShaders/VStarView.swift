//
//  VStarView.swift
//  ShaderKitDemo
//
//  V effect with radial mask fade creating starry effect
//

import SwiftUI
import ShaderKit

struct VStarView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HolographicCardContainer(
                width: 260,
                height: 380,
                shadowColor: .yellow
            ) {
                SimpleCardContent(
                    title: "VSTAR",
                    subtitle: "Star Rare",
                    gradientColors: [
                        Color(red: 0.25, green: 0.2, blue: 0.1),
                        Color(red: 0.2, green: 0.15, blue: 0.08),
                        Color(red: 0.28, green: 0.2, blue: 0.12)
                    ]
                )
                .radialStar(intensity: 0.75)
            }
        }
        .navigationTitle("VStar")
    }
}

#Preview {
    NavigationStack {
        VStarView()
    }
}
