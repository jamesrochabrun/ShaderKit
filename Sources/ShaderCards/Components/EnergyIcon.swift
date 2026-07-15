//
//  EnergyIcon.swift
//  ShaderCards
//
//  The circular elemental energy icon, drawn entirely in SwiftUI.
//

import SwiftUI

/// A circular energy icon for an element type.
///
/// Drawn with gradients and SF Symbols — no image assets — so it stays
/// crisp at every size.
public struct EnergyIcon: View {
  let element: ElementType
  let size: CGFloat

  public init(_ element: ElementType, size: CGFloat = 20) {
    self.element = element
    self.size = size
  }

  public var body: some View {
    let palette = element.palette
    ZStack {
      Circle()
        .fill(
          RadialGradient(
            colors: [palette.light, palette.primary, palette.dark],
            center: .init(x: 0.35, y: 0.3),
            startRadius: 0,
            endRadius: size * 0.75
          )
        )

      Circle()
        .strokeBorder(
          LinearGradient(
            colors: [.white.opacity(0.9), palette.dark.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: max(size * 0.05, 0.5)
        )

      Image(systemName: element.symbolName)
        .font(.system(size: size * 0.52, weight: .bold))
        .foregroundStyle(iconColor)
        .shadow(color: palette.dark.opacity(0.6), radius: size * 0.03, y: size * 0.02)
    }
    .frame(width: size, height: size)
    .accessibilityLabel("\(element.displayName) energy")
  }

  private var iconColor: Color {
    switch element {
    case .lightning, .colorless, .metal: element.palette.dark
    default: .white
    }
  }
}

#Preview("Energy Icons") {
  VStack(spacing: 12) {
    ForEach(ElementType.allCases) { element in
      HStack(spacing: 12) {
        EnergyIcon(element, size: 28)
        Text(element.displayName)
          .font(.caption)
      }
    }
  }
  .padding()
}
