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
            ) { tilt, elapsedTime in
                SimpleCardContent(
                    title: "COSMOS HOLO",
                    subtitle: "Galaxy Rare",
                    gradientColors: [
                        Color(red: 0.05, green: 0.02, blue: 0.15),
                        Color(red: 0.02, green: 0.02, blue: 0.1),
                        Color(red: 0.08, green: 0.02, blue: 0.12)
                    ]
                )
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.layerEffect(
                        ShaderKit.shaders.cosmosHoloEffect(
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
