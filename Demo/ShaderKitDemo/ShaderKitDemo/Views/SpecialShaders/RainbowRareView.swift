//
//  RainbowRareView.swift
//  ShaderKitDemo
//
//  Glittery rainbow effect with luminosity blending
//

import SwiftUI
import ShaderKit

struct RainbowRareView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HolographicCardContainer(
                width: 260,
                height: 380,
                shadowColor: .pink
            ) { tilt, elapsedTime in
                SimpleCardContent(
                    title: "RAINBOW RARE",
                    subtitle: "Secret Holo",
                    gradientColors: [
                        Color(red: 0.3, green: 0.2, blue: 0.4),
                        Color(red: 0.25, green: 0.15, blue: 0.35),
                        Color(red: 0.35, green: 0.2, blue: 0.4)
                    ]
                )
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.layerEffect(
                        ShaderKit.shaders.rainbowRareEffect(
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
        .navigationTitle("Rainbow Rare")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        RainbowRareView()
    }
}
