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
            ) { tilt, elapsedTime in
                SimpleCardContent(
                    title: "BASIC GLARE",
                    subtitle: "Common Card",
                    gradientColors: [
                        Color(red: 0.95, green: 0.9, blue: 0.8),
                        Color(red: 0.9, green: 0.85, blue: 0.75),
                        Color(red: 0.85, green: 0.8, blue: 0.7)
                    ]
                )
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.layerEffect(
                        ShaderKit.shaders.basicGlareEffect(
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
        .navigationTitle("Basic Glare")
    }
}

#Preview {
    NavigationStack {
        BasicGlareView()
    }
}
