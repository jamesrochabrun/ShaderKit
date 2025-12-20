//
//  HolographicModifiers.swift
//  ShaderKit
//
//  Collection of holographic card effect view modifiers
//

import SwiftUI

// MARK: - Shader Library Bundle

private let shaderLibrary: ShaderLibrary = {
  ShaderLibrary.bundle(.module)
}()

// MARK: - Card Three Holographic Effect

public struct CardThreeHolographicModifier: ViewModifier {
    public let tilt: CGPoint
    public let time: TimeInterval
    public let intensity: Double

    public init(tilt: CGPoint, time: TimeInterval, intensity: Double = 1.0) {
        self.tilt = tilt
        self.time = time
        self.intensity = intensity
    }

    public func body(content: Content) -> some View {
        content
            .drawingGroup()
            .visualEffect { view, proxy in
                view
                    .layerEffect(
                        shaderLibrary.cardThreeFoil(
                            .float2(proxy.size.width, proxy.size.height),
                            .float2(tilt.x, tilt.y),
                            .float(time),
                            .float(intensity)
                        ),
                        maxSampleOffset: .zero
                    )
                    .layerEffect(
                        shaderLibrary.cardThreeGlitter(
                            .float2(proxy.size.width, proxy.size.height),
                            .float2(tilt.x, tilt.y),
                            .float(time),
                            .float(50)
                        ),
                        maxSampleOffset: .zero
                    )
                    .layerEffect(
                        shaderLibrary.cardThreeSweep(
                            .float2(proxy.size.width, proxy.size.height),
                            .float2(tilt.x, tilt.y),
                            .float(time)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}

// MARK: - Card Four Holographic Effect

public struct CardFourHolographicModifier: ViewModifier {
    public let tilt: CGPoint
    public let time: TimeInterval
    public let intensity: Double

    public init(tilt: CGPoint, time: TimeInterval, intensity: Double = 1.0) {
        self.tilt = tilt
        self.time = time
        self.intensity = intensity
    }

    public func body(content: Content) -> some View {
        content
            .drawingGroup()
            .visualEffect { view, proxy in
                view
                    .layerEffect(
                        shaderLibrary.cardFourStarburst(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(time),
                            .float(intensity)
                        ),
                        maxSampleOffset: .zero
                    )
                    .layerEffect(
                        shaderLibrary.cardFourSweep(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(time)
                        ),
                        maxSampleOffset: .zero
                    )
                    .layerEffect(
                        shaderLibrary.cardFourGlitter(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(time),
                            .float(80)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}

// MARK: - Card Five Effects

public struct CardFiveBackgroundHoloModifier: ViewModifier {
    public let tilt: CGPoint
    public let time: TimeInterval
    public var intensity: Float
    public var saturation: Float

    public init(tilt: CGPoint, time: TimeInterval, intensity: Float = 0.7, saturation: Float = 0.75) {
        self.tilt = tilt
        self.time = time
        self.intensity = intensity
        self.saturation = saturation
    }

    public func body(content: Content) -> some View {
        content
            .drawingGroup()
            .visualEffect { view, proxy in
                view
                    .layerEffect(
                        shaderLibrary.cardFiveBlendedHolo(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(time),
                            .float(intensity),
                            .float(saturation)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}

public struct CardFiveImageSparklesModifier: ViewModifier {
    public let tilt: CGPoint
    public let time: TimeInterval

    public init(tilt: CGPoint, time: TimeInterval) {
        self.tilt = tilt
        self.time = time
    }

    public func body(content: Content) -> some View {
        content
            .drawingGroup()
            .visualEffect { view, proxy in
                view
                    .layerEffect(
                        shaderLibrary.cardFiveSparkles(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(time)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}

public struct CardFiveSweepModifier: ViewModifier {
    public let tilt: CGPoint
    public let time: TimeInterval

    public init(tilt: CGPoint, time: TimeInterval) {
        self.tilt = tilt
        self.time = time
    }

    public func body(content: Content) -> some View {
        content
            .drawingGroup()
            .visualEffect { view, proxy in
                view
                    .layerEffect(
                        shaderLibrary.cardFiveSweep(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(time)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}

// MARK: - Card Six Reverse Holo Effect

public struct CardSixReverseHoloModifier: ViewModifier {
    public let tilt: CGPoint
    public let time: TimeInterval
    public let imageWindow: SIMD4<Float>
    public var foilIntensity: Double

    public init(tilt: CGPoint, time: TimeInterval, imageWindow: SIMD4<Float>, foilIntensity: Double = 1.0) {
        self.tilt = tilt
        self.time = time
        self.imageWindow = imageWindow
        self.foilIntensity = foilIntensity
    }

    public func body(content: Content) -> some View {
        content
            .drawingGroup()
            .visualEffect { view, proxy in
                view
                    .layerEffect(
                        shaderLibrary.cardSixReverseHolo(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(time),
                            .float4(
                                imageWindow.x,
                                imageWindow.y,
                                imageWindow.z,
                                imageWindow.w
                            ),
                            .float(foilIntensity)
                        ),
                        maxSampleOffset: .zero
                    )
                    .layerEffect(
                        shaderLibrary.cardSixSparkle(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float(time),
                            .float4(
                                imageWindow.x,
                                imageWindow.y,
                                imageWindow.z,
                                imageWindow.w
                            )
                        ),
                        maxSampleOffset: .zero
                    )
                    .layerEffect(
                        shaderLibrary.cardSixFoilTexture(
                            .float2(proxy.size),
                            .float2(tilt),
                            .float4(
                                imageWindow.x,
                                imageWindow.y,
                                imageWindow.z,
                                imageWindow.w
                            )
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}

// MARK: - View Extensions

public extension View {
    func cardThreeHolographicEffect(tilt: CGPoint, time: TimeInterval, intensity: Double = 1.0) -> some View {
        modifier(CardThreeHolographicModifier(tilt: tilt, time: time, intensity: intensity))
    }

    func cardFourHolographicEffect(tilt: CGPoint, time: TimeInterval, intensity: Double = 1.0) -> some View {
        modifier(CardFourHolographicModifier(tilt: tilt, time: time, intensity: intensity))
    }

    func cardFiveBackgroundHolo(
        tilt: CGPoint,
        time: TimeInterval,
        intensity: Float = 0.7,
        saturation: Float = 0.75
    ) -> some View {
        modifier(CardFiveBackgroundHoloModifier(
            tilt: tilt,
            time: time,
            intensity: intensity,
            saturation: saturation
        ))
    }

    func cardFiveImageSparkles(
        tilt: CGPoint,
        time: TimeInterval
    ) -> some View {
        modifier(CardFiveImageSparklesModifier(
            tilt: tilt,
            time: time
        ))
    }

    func cardFiveSweep(
        tilt: CGPoint,
        time: TimeInterval
    ) -> some View {
        modifier(CardFiveSweepModifier(
            tilt: tilt,
            time: time
        ))
    }

    func cardSixReverseHoloEffect(
        tilt: CGPoint,
        time: TimeInterval,
        imageWindow: SIMD4<Float>,
        foilIntensity: Double = 1.0
    ) -> some View {
        modifier(CardSixReverseHoloModifier(
            tilt: tilt,
            time: time,
            imageWindow: imageWindow,
            foilIntensity: foilIntensity
        ))
    }
}
