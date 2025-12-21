# ShaderKit

A Swift package for composable Metal shaders and holographic UI effects in SwiftUI.

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS 17+](https://img.shields.io/badge/iOS-17+-blue.svg)](https://developer.apple.com)
[![macOS 14+](https://img.shields.io/badge/macOS-14+-blue.svg)](https://developer.apple.com)

## Quick Start

Create holographic cards with composable shader effects:

```swift
import ShaderKit

HolographicCardContainer(width: 260, height: 380) {
    CardContent()
        .foil()
        .glitter()
        .lightSweep()
}
```

The `HolographicCardContainer` provides:
- Device motion tracking via gyroscope
- Drag gesture for manual tilt control
- 3D rotation effects synchronized with tilt
- Dynamic shadow based on tilt angle
- Automatic shader context injection

## Installation

### Swift Package Manager

Add ShaderKit to your project via Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL
3. Select your version requirements

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jamesrochabrun/ShaderKit.git", from: "2.0.0")
]
```

## Available Shaders

ShaderKit provides 27 composable shader effects across 4 categories.

### Foil Effects

| Effect | Description | Parameters |
|--------|-------------|------------|
| `.foil()` | Rainbow foil overlay | `intensity: Double = 1.0` |
| `.invertedFoil()` | Inverted foil with shine | `intensity: Double = 0.7` |
| `.maskedFoil()` | Foil with masked area | `imageWindow: SIMD4<Float>, intensity: Double = 1.0` |
| `.foilTexture()` | Fine diagonal line texture | `imageWindow: SIMD4<Float>` |

### Glitter & Sparkle

| Effect | Description | Parameters |
|--------|-------------|------------|
| `.glitter()` | Sparkle particle overlay | `density: Double = 50` |
| `.multiGlitter()` | Multi-scale sparkle particles | `density: Double = 80` |
| `.sparkles()` | Tilt-activated sparkle grid | - |
| `.maskedSparkle()` | Sparkles in masked area only | `imageWindow: SIMD4<Float>` |
| `.rainbowGlitter()` | Rainbow with luminosity blend | `intensity: Double = 0.7` |
| `.shimmer()` | Metallic shimmer effect | `intensity: Double = 0.7` |

### Light Effects

| Effect | Description | Parameters |
|--------|-------------|------------|
| `.lightSweep()` | Sweeping light band | - |
| `.radialSweep()` | Rotating radial light sweep | - |
| `.angledSweep()` | Angled light sweep | - |
| `.glare()` | Following light hotspot | `intensity: Double = 1.0` |
| `.simpleGlare()` | Simple radial glare | `intensity: Double = 0.7` |
| `.edgeShine()` | Edge highlight effect | - |

### Holographic Patterns

| Effect | Description | Parameters |
|--------|-------------|------------|
| `.diamondGrid()` | Diamond grid pattern | `intensity: Double = 1.0` |
| `.intenseBling()` | Maximum intensity diamond holo | - |
| `.starburst()` | Radial rainbow rays from center | `intensity: Double = 1.0` |
| `.blendedHolo()` | Luminance-blended rainbow | `intensity: Float = 0.7, saturation: Float = 0.75` |
| `.verticalBeams()` | Vertical rainbow beam pattern | `intensity: Double = 0.7` |
| `.diagonalHolo()` | Diagonal lines with 3D depth | `intensity: Double = 0.7` |
| `.crisscrossHolo()` | Criss-cross diamond pattern | `intensity: Double = 0.7` |
| `.galaxyHolo()` | Galaxy/cosmos with rainbow overlay | `intensity: Double = 0.7` |
| `.radialStar()` | Star pattern with radial fade | `intensity: Double = 0.7` |
| `.subtleGradient()` | Large-scale subtle gradient | `intensity: Double = 0.7` |
| `.metallicCrosshatch()` | Metallic sun-pillar with crosshatch | `intensity: Double = 0.7` |

## Composing Effects

Chain multiple effects to create unique combinations:

```swift
// Holographic trading card
HolographicCardContainer(width: 260, height: 380) {
    CardContent()
        .foil()
        .glitter()
        .lightSweep()
}

// Premium gold card with starburst
HolographicCardContainer(
    width: 280,
    height: 400,
    shadowColor: .yellow,
    rotationMultiplier: 12
) {
    CardContent()
        .starburst()
        .radialSweep()
        .multiGlitter()
}

// Psychic holographic effect
HolographicCardContainer(width: 280, height: 400, shadowColor: .purple) {
    CardContent()
        .foil()
        .glitter()
        .lightSweep()
}

// Layered effect with blended holo
HolographicCardContainer(width: 260, height: 364, shadowColor: .yellow) {
    ZStack {
        BackgroundLayer()
            .blendedHolo(intensity: 0.7, saturation: 0.75)

        SparkleLayer()
            .sparkles()

        ArtworkLayer()
    }
    .angledSweep()
}
```

## Custom Tilt Source

For custom tilt control without `HolographicCardContainer`:

```swift
CardContent()
    .shaderContext(tilt: myTiltPoint, time: elapsedTime)
    .shader(.foil(intensity: 0.8))
    .shader(.glitter(density: 75))
    .shader(.lightSweep)
```

## Using the Builder API

Apply effects using the generic `.shader()` modifier:

```swift
CardContent()
    .shaderContext(tilt: tilt, time: time)
    .shader(.foil(intensity: 0.8))
    .shader(.glitter())
    .shader(.lightSweep)
```

## Masked Effects

Apply effects only to specific areas using UV coordinates:

```swift
// Define image window bounds (UV space 0-1)
let imageWindow = SIMD4<Float>(
    0.04,   // minX
    0.11,   // minY
    0.96,   // maxX
    0.55    // maxY
)

CardContent()
    .maskedFoil(imageWindow: imageWindow)
    .maskedSparkle(imageWindow: imageWindow)
    .foilTexture(imageWindow: imageWindow)
```

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- Xcode 15+

## License

MIT License
