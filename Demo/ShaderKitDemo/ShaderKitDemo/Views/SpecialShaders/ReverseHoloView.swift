//
//  ReverseHoloView.swift
//  ShaderKitDemo
//
//  Inverted foil effect with shine overlay
//

import SwiftUI
import ShaderKit

struct ReverseHoloView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            HolographicCardContainer(
                width: 260,
                height: 380,
                shadowColor: .green
            ) { tilt, elapsedTime in
                SimpleCardContent(
                    title: "REVERSE HOLO",
                    subtitle: "Non-Rare Holo",
                    image: "lion",
                    gradientColors: []
                )
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.layerEffect(
                        ShaderKit.shaders.reverseHoloEffect(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(Float(elapsedTime)),
                            .float(0.7)
                        ),
                        maxSampleOffset: .zero
                    )
                }
            }
        }
        .navigationTitle("Reverse Holo")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        ReverseHoloView()
    }
}
