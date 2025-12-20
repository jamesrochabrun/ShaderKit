//
//  AmazingRareView.swift
//  ShaderKitDemo
//
//  Glittery metallic shimmer effect
//

import SwiftUI
import ShaderKit

struct AmazingRareView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HolographicCardContainer(
                width: 260,
                height: 380,
                shadowColor: .mint
            ) { tilt, elapsedTime in
                SimpleCardContent(
                    title: "AMAZING RARE",
                    subtitle: "Amazing Holo",
                    gradientColors: [
                        Color(red: 0.18, green: 0.22, blue: 0.25),
                        Color(red: 0.12, green: 0.15, blue: 0.18),
                        Color(red: 0.2, green: 0.2, blue: 0.25)
                    ]
                )
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.layerEffect(
                        ShaderKit.shaders.amazingRareEffect(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(Float(elapsedTime)),
                            .float(0.8)
                        ),
                        maxSampleOffset: .zero
                    )
                }
            }
        }
        .navigationTitle("Amazing Rare")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        AmazingRareView()
    }
}
