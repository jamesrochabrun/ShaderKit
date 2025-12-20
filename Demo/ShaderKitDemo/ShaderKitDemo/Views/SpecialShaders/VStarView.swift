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
            ) { tilt, elapsedTime in
                SimpleCardContent(
                    title: "VSTAR",
                    subtitle: "Star Rare",
                    gradientColors: [
                        Color(red: 0.25, green: 0.2, blue: 0.1),
                        Color(red: 0.2, green: 0.15, blue: 0.08),
                        Color(red: 0.28, green: 0.2, blue: 0.12)
                    ]
                )
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.layerEffect(
                        ShaderKit.shaders.vstarEffect(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(Float(elapsedTime)),
                            .float(0.75)
                        ),
                        maxSampleOffset: .zero
                    )
                }
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
