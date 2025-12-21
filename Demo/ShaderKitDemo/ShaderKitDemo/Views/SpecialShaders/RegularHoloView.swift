//
//  RegularHoloView.swift
//  ShaderKitDemo
//
//  Rainbow vertical beam holographic effect
//

import SwiftUI
import ShaderKit

struct RegularHoloView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HolographicCardContainer(
                width: 260,
                height: 380,
                shadowColor: .cyan
            ) {
                SimpleCardContent(
                    title: "REGULAR HOLO",
                    subtitle: "Holofoil Rare",
                    gradientColors: [
                        Color(red: 0.15, green: 0.2, blue: 0.35),
                        Color(red: 0.1, green: 0.15, blue: 0.3),
                        Color(red: 0.2, green: 0.15, blue: 0.35)
                    ]
                )
                .verticalBeams(intensity: 0.7)
            }
        }
        .navigationTitle("Regular Holo")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        RegularHoloView()
    }
}
