//
//  TrainerCardFace.swift
//  ShaderCards
//
//  Trainer card layout: kind banner, art window, and rules text panel.
//

import SwiftUI
import ShaderKit

/// The trainer card face (supporter / item / stadium).
struct TrainerCardFace: View {
  let card: TrainerCardModel
  let metrics: CardMetrics.Resolved
  let finish: CardFinish
  /// Which slice of the face to render.
  var layerMode: FaceLayerMode = .full
  /// How the art window renders (ignored in `.frameOnly` mode).
  var artTreatment: ArtWindowTreatment = .artwork

  private var kindColor: Color {
    switch card.kind {
    case .supporter: Color(red: 0.90, green: 0.42, blue: 0.15)
    case .item: Color(red: 0.20, green: 0.55, blue: 0.80)
    case .stadium: Color(red: 0.35, green: 0.65, blue: 0.35)
    }
  }

  var body: some View {
    switch layerMode {
    case .full:
      frameBase
        .overlay(alignment: .top) { content }
    case .frameOnly:
      frameBase
    case .chromeOnly:
      Color.clear
        .overlay(alignment: .top) { content }
    }
  }

  private var frameBase: some View {
    RoundedRectangle(cornerRadius: metrics.cornerRadius)
      .fill(
        LinearGradient(
          colors: [Color(white: 0.96), Color(white: 0.82), Color(white: 0.90)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .overlay(FramePinstripes(spacing: metrics.width * 0.02).opacity(0.35))
      .overlay(
        RoundedRectangle(cornerRadius: metrics.cornerRadius)
          .strokeBorder(.black.opacity(0.3), lineWidth: 0.75)
      )
  }

  private var content: some View {
    VStack(spacing: metrics.height * 0.010) {
      // Kind banner + name.
      VStack(alignment: .leading, spacing: metrics.width * 0.006) {
        Text(card.kind.displayName)
          .font(.system(size: metrics.captionSize, weight: .heavy))
          .textCase(.uppercase)
          .foregroundStyle(.white)
          .padding(.horizontal, metrics.width * 0.025)
          .padding(.vertical, metrics.width * 0.006)
          .background(
            UnevenRoundedRectangle(
              topLeadingRadius: metrics.cornerRadius * 0.4,
              bottomTrailingRadius: metrics.cornerRadius * 0.8
            )
            .fill(kindColor)
          )

        Text(card.name)
          .font(CardTypography.name(metrics))
          .foregroundStyle(.black)
          .lineLimit(1)
          .minimumScaleFactor(0.6)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(height: metrics.headerHeight * 1.15, alignment: .top)

      ArtWindow(metrics: metrics) {
        Group {
          switch artTreatment {
          case .artwork:
            TrainerArtworkView(artwork: card.artwork)
          case .dark:
            LinearGradient(
              colors: [Color(white: 0.10), Color(white: 0.16)],
              startPoint: .top,
              endPoint: .bottom
            )
          case .transparent:
            Color.clear
          }
        }
        .frame(width: metrics.width - metrics.border * 2, height: metrics.artHeight)
      }
      .frame(height: metrics.artHeight)

      // Rules text panel.
      Text(card.text)
        .font(CardTypography.body(metrics))
        .foregroundStyle(.black.opacity(0.85))
        .multilineTextAlignment(.leading)
        .lineLimit(8)
        .minimumScaleFactor(0.7)
        .fixedSize(horizontal: false, vertical: true)
        .padding(metrics.width * 0.03)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
          RoundedRectangle(cornerRadius: metrics.cornerRadius * 0.5)
            .fill(.white.opacity(0.75))
            .overlay(
              RoundedRectangle(cornerRadius: metrics.cornerRadius * 0.5)
                .strokeBorder(kindColor.opacity(0.5), lineWidth: 1)
            )
        )

      InfoLine(
        setNumber: card.setNumber,
        illustrator: card.illustrator,
        rarity: card.rarity,
        metrics: metrics
      )
    }
    .padding(metrics.border)
  }
}

/// Procedural scenes for trainer cards — abstract still-life compositions.
struct TrainerArtworkView: View {
  let artwork: TrainerArtwork

  var body: some View {
    GeometryReader { proxy in
      let size = proxy.size
      switch artwork {
      case .potion:
        ZStack {
          LinearGradient(
            colors: [Color(red: 0.55, green: 0.75, blue: 0.90), Color(red: 0.85, green: 0.94, blue: 1.0)],
            startPoint: .top, endPoint: .bottom
          )
          PotionBottle()
            .frame(width: size.width * 0.32, height: size.height * 0.62)
            .position(x: size.width * 0.5, y: size.height * 0.58)
        }
      case .researchLab:
        ZStack {
          LinearGradient(
            colors: [Color(red: 0.25, green: 0.30, blue: 0.45), Color(red: 0.55, green: 0.62, blue: 0.78)],
            startPoint: .top, endPoint: .bottom
          )
          TerrainView(
            kind: .cityscape,
            colors: [Color(red: 0.35, green: 0.42, blue: 0.58), Color(red: 0.20, green: 0.25, blue: 0.38)],
            seed: 201
          )
        }
      case .travelMap:
        ZStack {
          LinearGradient(
            colors: [Color(red: 0.93, green: 0.87, blue: 0.72), Color(red: 0.85, green: 0.75, blue: 0.55)],
            startPoint: .topLeading, endPoint: .bottomTrailing
          )
          DottedTrail()
            .stroke(
              Color(red: 0.60, green: 0.30, blue: 0.15),
              style: StrokeStyle(lineWidth: size.width * 0.012, dash: [size.width * 0.03, size.width * 0.025])
            )
            .padding(size.width * 0.1)
          StarShape(points: 5)
            .fill(Color(red: 0.85, green: 0.25, blue: 0.20))
            .frame(width: size.width * 0.09, height: size.width * 0.09)
            .position(x: size.width * 0.78, y: size.height * 0.30)
        }
      case .trainingGrounds:
        ZStack {
          LinearGradient(
            colors: [Color(red: 0.95, green: 0.70, blue: 0.35), Color(red: 0.70, green: 0.42, blue: 0.20)],
            startPoint: .top, endPoint: .bottom
          )
          TerrainView(
            kind: .mountains,
            colors: [Color(red: 0.62, green: 0.38, blue: 0.20), Color(red: 0.42, green: 0.24, blue: 0.12)],
            seed: 202
          )
        }
      case .crystalCavern:
        ZStack {
          LinearGradient(
            colors: [Color(red: 0.10, green: 0.08, blue: 0.25), Color(red: 0.32, green: 0.22, blue: 0.52)],
            startPoint: .top, endPoint: .bottom
          )
          TerrainView(
            kind: .crystals,
            colors: [Color(red: 0.45, green: 0.35, blue: 0.75), Color(red: 0.28, green: 0.18, blue: 0.50)],
            seed: 203
          )
        }
      case .midnightMarket:
        ZStack {
          LinearGradient(
            colors: [Color(red: 0.08, green: 0.06, blue: 0.16), Color(red: 0.30, green: 0.15, blue: 0.28)],
            startPoint: .top, endPoint: .bottom
          )
          TerrainView(
            kind: .cityscape,
            colors: [Color(red: 0.22, green: 0.14, blue: 0.30), Color(red: 0.12, green: 0.07, blue: 0.18)],
            seed: 204
          )
        }
      }
    }
    .clipped()
  }
}

/// A rounded potion bottle with a cork.
private struct PotionBottle: View {
  var body: some View {
    GeometryReader { proxy in
      let w = proxy.size.width
      let h = proxy.size.height
      ZStack {
        // Bottle body.
        Circle()
          .fill(
            RadialGradient(
              colors: [Color(red: 0.85, green: 0.45, blue: 0.75), Color(red: 0.55, green: 0.15, blue: 0.45)],
              center: .init(x: 0.35, y: 0.3),
              startRadius: 0,
              endRadius: w * 0.7
            )
          )
          .frame(width: w, height: w)
          .position(x: w * 0.5, y: h - w * 0.5)
        // Neck.
        RoundedRectangle(cornerRadius: w * 0.05)
          .fill(Color(red: 0.75, green: 0.35, blue: 0.62))
          .frame(width: w * 0.3, height: h * 0.28)
          .position(x: w * 0.5, y: h * 0.24)
        // Cork.
        RoundedRectangle(cornerRadius: w * 0.06)
          .fill(Color(red: 0.72, green: 0.52, blue: 0.32))
          .frame(width: w * 0.36, height: h * 0.12)
          .position(x: w * 0.5, y: h * 0.08)
        // Shine.
        Capsule()
          .fill(.white.opacity(0.55))
          .frame(width: w * 0.1, height: w * 0.32)
          .rotationEffect(.degrees(20))
          .position(x: w * 0.32, y: h - w * 0.62)
      }
    }
  }
}

/// A meandering dotted path for the travel map.
private struct DottedTrail: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY * 0.85))
    path.addCurve(
      to: CGPoint(x: rect.maxX * 0.78, y: rect.minY + rect.height * 0.30),
      control1: CGPoint(x: rect.width * 0.35, y: rect.maxY * 1.0),
      control2: CGPoint(x: rect.width * 0.55, y: rect.minY + rect.height * 0.15)
    )
    return path
  }
}
