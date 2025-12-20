//
//  PokemonVView.swift
//  ShaderKitDemo
//
//  Diagonal holographic effect with parallel lines
//

import SwiftUI
import ShaderKit

struct PokemonVView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HolographicCardContainer(
                width: 260,
                height: 380,
                shadowColor: .orange
            ) { tilt, elapsedTime in
                SimpleCardContent(
                    title: "POKEMON V",
                    subtitle: "Ultra Rare",
                    image: "puppy",
                    gradientColors: [
                        Color(red: 0.2, green: 0.15, blue: 0.1),
                        Color(red: 0.15, green: 0.1, blue: 0.08),
                        Color(red: 0.25, green: 0.15, blue: 0.1)
                    ]
                )
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.layerEffect(
                        ShaderKit.shaders.pokemonVEffect(
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
        .navigationTitle("Pokemon V")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        PokemonVView()
    }
}
