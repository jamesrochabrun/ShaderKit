//
//  VMaxView.swift
//  ShaderKitDemo
//
//  Large-scale subtle gradient with pronounced texture
//

import SwiftUI
import ShaderKit

struct VMaxView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HolographicCardContainer(
                width: 260,
                height: 380,
                shadowColor: .blue
            ) {
                SimpleCardContent(
                    title: "VMAX",
                    subtitle: "Gigantamax Rare",
                    gradientColors: [
                        Color(red: 0.1, green: 0.15, blue: 0.25),
                        Color(red: 0.08, green: 0.1, blue: 0.2),
                        Color(red: 0.12, green: 0.12, blue: 0.22)
                    ]
                )
                .subtleGradient(intensity: 0.7)
            }
        }
        .navigationTitle("VMax")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        VMaxView()
    }
}
