//
//  SecretGoldView.swift
//  ShaderKitDemo
//
//  Shimmering gold glitter overlay effect
//

import SwiftUI
import ShaderKit

struct SecretGoldView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HolographicCardContainer(
                width: 260,
                height: 380,
                shadowColor: .yellow
            ) { tilt, elapsedTime in
                SimpleCardContent(
                    title: "SECRET GOLD",
                    subtitle: "Secret Rare",
                    gradientColors: [
                        Color(red: 0.3, green: 0.25, blue: 0.1),
                        Color(red: 0.25, green: 0.2, blue: 0.08),
                        Color(red: 0.35, green: 0.28, blue: 0.1)
                    ]
                )
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.layerEffect(
                        ShaderKit.shaders.secretGoldEffect(
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
        .navigationTitle("Secret Gold")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        SecretGoldView()
    }
}
