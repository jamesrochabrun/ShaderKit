//
//  ShinyRareView.swift
//  ShaderKitDemo
//
//  Metallic sun-pillar effect with crosshatch texture
//

import SwiftUI
import ShaderKit

struct ShinyRareView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HolographicCardContainer(
                width: 260,
                height: 380,
                shadowColor: .white
            ) { tilt, elapsedTime in
                SimpleCardContent(
                    title: "SHINY RARE",
                    subtitle: "Ultra Metallic",
                    gradientColors: [
                        Color(red: 0.2, green: 0.2, blue: 0.22),
                        Color(red: 0.15, green: 0.15, blue: 0.18),
                        Color(red: 0.22, green: 0.2, blue: 0.25)
                    ]
                )
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.layerEffect(
                        ShaderKit.shaders.shinyRareEffect(
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
        .navigationTitle("Shiny Rare")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        ShinyRareView()
    }
}
