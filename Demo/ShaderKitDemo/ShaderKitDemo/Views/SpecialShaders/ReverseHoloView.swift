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
            ) {
                SimpleCardContent(
                    title: "REVERSE HOLO",
                    subtitle: "Non-Rare Holo",
                    image: "lion",
                    gradientColors: []
                )
                .invertedFoil(intensity: 0.7)
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
