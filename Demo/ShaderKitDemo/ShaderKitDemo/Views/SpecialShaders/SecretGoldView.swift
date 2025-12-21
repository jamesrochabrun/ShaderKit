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
            ) {
                SimpleCardContent(
                    title: "SECRET GOLD",
                    subtitle: "Secret Rare",
                    gradientColors: [
                        Color(red: 0.3, green: 0.25, blue: 0.1),
                        Color(red: 0.25, green: 0.2, blue: 0.08),
                        Color(red: 0.35, green: 0.28, blue: 0.1)
                    ]
                )
                .goldShimmer(intensity: 0.8)
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
