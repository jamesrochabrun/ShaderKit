//
//  Backdrops.swift
//  ShaderCards
//
//  Parametric scenery silhouettes: mountains, waves, forests, dunes,
//  clouds, crystals, and skylines.
//

import SwiftUI

/// A jagged mountain-range silhouette.
struct MountainRange: Shape {
  var peaks: Int
  var seed: UInt64
  /// Peak height as fraction of rect height (0–1).
  var amplitude: CGFloat = 0.7

  func path(in rect: CGRect) -> Path {
    var random = SceneRandom(seed: seed)
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

    let step = rect.width / CGFloat(peaks)
    var x = rect.minX
    path.addLine(to: CGPoint(x: x, y: rect.maxY - rect.height * random.range(0.2...0.5)))
    for _ in 0..<peaks {
      let peakX = x + step * random.range(0.3...0.7)
      let peakY = rect.maxY - rect.height * random.range(0.55...1.0) * amplitude
      let valleyX = x + step
      let valleyY = rect.maxY - rect.height * random.range(0.1...0.35)
      path.addLine(to: CGPoint(x: peakX, y: peakY))
      path.addLine(to: CGPoint(x: valleyX, y: valleyY))
      x += step
    }
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

/// A rolling ocean-wave band.
struct WaveBand: Shape {
  var waves: Int
  var seed: UInt64
  var amplitude: CGFloat = 0.5

  func path(in rect: CGRect) -> Path {
    var random = SceneRandom(seed: seed)
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

    let step = rect.width / CGFloat(waves)
    let baseY = rect.maxY - rect.height * 0.5
    path.addLine(to: CGPoint(x: rect.minX, y: baseY))
    var x = rect.minX
    for _ in 0..<waves {
      let crestHeight = rect.height * random.range(0.3...0.6) * amplitude
      path.addCurve(
        to: CGPoint(x: x + step, y: baseY),
        control1: CGPoint(x: x + step * 0.35, y: baseY - crestHeight),
        control2: CGPoint(x: x + step * 0.6, y: baseY + crestHeight * 0.4)
      )
      x += step
    }
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

/// A row of stylized conifer trees.
struct ForestLine: Shape {
  var trees: Int
  var seed: UInt64

  func path(in rect: CGRect) -> Path {
    var random = SceneRandom(seed: seed)
    var path = Path()
    let step = rect.width / CGFloat(trees)

    for i in 0..<trees {
      let cx = rect.minX + step * (CGFloat(i) + 0.5)
      let treeHeight = rect.height * random.range(0.55...1.0)
      let halfWidth = step * random.range(0.35...0.5)
      let top = CGPoint(x: cx, y: rect.maxY - treeHeight)

      // Three stacked triangle tiers.
      for tier in 0..<3 {
        let t = CGFloat(tier)
        let tierTop = top.y + treeHeight * t * 0.22
        let tierBottom = top.y + treeHeight * (t + 1.6) * 0.24
        let tierHalf = halfWidth * (0.5 + t * 0.28)
        path.move(to: CGPoint(x: cx, y: tierTop))
        path.addLine(to: CGPoint(x: cx - tierHalf, y: tierBottom))
        path.addLine(to: CGPoint(x: cx + tierHalf, y: tierBottom))
        path.closeSubpath()
      }
    }
    // Ground strip so trees sit on something.
    path.addRect(CGRect(x: rect.minX, y: rect.maxY - rect.height * 0.08,
                        width: rect.width, height: rect.height * 0.08))
    return path
  }
}

/// Soft rolling sand dunes.
struct DuneShape: Shape {
  var seed: UInt64

  func path(in rect: CGRect) -> Path {
    var random = SceneRandom(seed: seed)
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    let startY = rect.maxY - rect.height * random.range(0.3...0.6)
    path.addLine(to: CGPoint(x: rect.minX, y: startY))
    path.addCurve(
      to: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * random.range(0.2...0.5)),
      control1: CGPoint(x: rect.width * random.range(0.25...0.4), y: startY - rect.height * 0.4),
      control2: CGPoint(x: rect.width * random.range(0.6...0.75), y: rect.maxY)
    )
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

/// A drifting bank of rounded clouds.
struct CloudBank: Shape {
  var puffs: Int
  var seed: UInt64

  func path(in rect: CGRect) -> Path {
    var random = SceneRandom(seed: seed)
    var path = Path()
    for _ in 0..<puffs {
      let radius = rect.height * random.range(0.18...0.42)
      let x = rect.minX + rect.width * random.unit()
      let y = rect.minY + rect.height * random.range(0.3...0.8)
      path.addEllipse(in: CGRect(x: x - radius, y: y - radius * 0.7,
                                 width: radius * 2, height: radius * 1.4))
    }
    return path
  }
}

/// Jagged crystal shards rising from the ground.
struct CrystalField: Shape {
  var shards: Int
  var seed: UInt64

  func path(in rect: CGRect) -> Path {
    var random = SceneRandom(seed: seed)
    var path = Path()
    let step = rect.width / CGFloat(shards)
    for i in 0..<shards {
      let cx = rect.minX + step * (CGFloat(i) + random.range(0.3...0.7))
      let height = rect.height * random.range(0.4...1.0)
      let halfWidth = step * random.range(0.18...0.3)
      let lean = step * random.range(-0.2...0.2)
      path.move(to: CGPoint(x: cx - halfWidth, y: rect.maxY))
      path.addLine(to: CGPoint(x: cx + lean, y: rect.maxY - height))
      path.addLine(to: CGPoint(x: cx + lean + halfWidth * 0.35, y: rect.maxY - height * 0.82))
      path.addLine(to: CGPoint(x: cx + halfWidth, y: rect.maxY))
      path.closeSubpath()
    }
    return path
  }
}

/// A distant city skyline of rectangular towers.
struct Skyline: Shape {
  var towers: Int
  var seed: UInt64

  func path(in rect: CGRect) -> Path {
    var random = SceneRandom(seed: seed)
    var path = Path()
    let step = rect.width / CGFloat(towers)
    for i in 0..<towers {
      let x = rect.minX + step * CGFloat(i)
      let width = step * random.range(0.55...0.9)
      let height = rect.height * random.range(0.35...1.0)
      path.addRect(CGRect(x: x, y: rect.maxY - height, width: width, height: height))
    }
    return path
  }
}

/// Renders the terrain silhouettes for a scene, far to near.
struct TerrainView: View {
  let kind: TerrainKind
  let colors: [Color]
  let seed: UInt64

  var body: some View {
    GeometryReader { proxy in
      let size = proxy.size
      ZStack(alignment: .bottom) {
        ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
          let depth = CGFloat(index)  // 0 = farthest
          let layerHeight = size.height * (0.30 + depth * 0.10)
          terrainShape(layer: index)
            .fill(color)
            .frame(height: layerHeight)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
      }
    }
  }

  private func terrainShape(layer: Int) -> AnyShape {
    let layerSeed = seed &+ UInt64(layer &* 977)
    return switch kind {
    case .mountains: AnyShape(MountainRange(peaks: 3 + layer * 2, seed: layerSeed))
    case .waves: AnyShape(WaveBand(waves: 3 + layer * 2, seed: layerSeed))
    case .forest: AnyShape(ForestLine(trees: 4 + layer * 3, seed: layerSeed))
    case .dunes: AnyShape(DuneShape(seed: layerSeed))
    case .clouds: AnyShape(CloudBank(puffs: 5 + layer * 2, seed: layerSeed))
    case .crystals: AnyShape(CrystalField(shards: 4 + layer * 2, seed: layerSeed))
    case .cityscape: AnyShape(Skyline(towers: 6 + layer * 3, seed: layerSeed))
    case .none: AnyShape(EmptyShape())
    }
  }
}

/// A shape that draws nothing.
struct EmptyShape: Shape {
  func path(in rect: CGRect) -> Path { Path() }
}
