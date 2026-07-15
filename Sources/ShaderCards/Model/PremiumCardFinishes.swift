//
//  PremiumCardFinishes.swift
//  ShaderCards
//
//  Opaque material recipes built from ShaderKit's premium surface shaders.
//

import ShaderKit

public extension CardFinish {
  /// Satin aerospace titanium with a restrained clear-coat reflection.
  static var brushedTitanium: CardFinish {
    CardFinish(
      cardEffects: [
        .brushedTitanium(intensity: 0.88),
        .glassSheen(intensity: 0.16, spread: 0.72),
      ],
      isFullArt: true
    )
  }

  /// Near-black mirror chrome with a crisp glass highlight.
  static var blackChrome: CardFinish {
    CardFinish(
      cardEffects: [
        .blackChrome(intensity: 0.90),
        .glassSheen(intensity: 0.14, spread: 0.52),
      ],
      isFullArt: true
    )
  }

  /// Warm rose-gold plating with a soft glossy clear coat.
  static var roseGold: CardFinish {
    CardFinish(
      cardEffects: [
        .roseGold(intensity: 0.86),
        .glassSheen(intensity: 0.18, spread: 0.62),
      ],
      isFullArt: true
    )
  }

  /// Animated mirror-silver folds under a tight surface reflection.
  static var liquidMercury: CardFinish {
    CardFinish(
      cardEffects: [
        .liquidMercury(intensity: 0.86),
        .glassSheen(intensity: 0.14, spread: 0.46),
      ],
      isFullArt: true
    )
  }

  /// Heat-treated titanium with angle-dependent oxide colors.
  static var anodizedTitanium: CardFinish {
    CardFinish(
      cardEffects: [
        .anodizedTitanium(intensity: 0.88),
        .lightSweep,
      ],
      isFullArt: true
    )
  }

  /// Wavy forged-steel layers under a subtle clear coat.
  static var damascusSteel: CardFinish {
    CardFinish(
      cardEffects: [
        .damascusSteel(intensity: 0.90),
        .glassSheen(intensity: 0.12, spread: 0.66),
      ],
      isFullArt: true
    )
  }

  /// Matte chopped-carbon composite with a narrow moving reflection.
  static var forgedCarbon: CardFinish {
    CardFinish(
      cardEffects: [
        .forgedCarbon(intensity: 0.92),
        .glassSheen(intensity: 0.10, spread: 0.38),
      ],
      isFullArt: true
    )
  }

  /// Weathered copper with organic turquoise oxidation.
  static var copperPatina: CardFinish {
    CardFinish(
      cardEffects: [
        .copperPatina(intensity: 0.88),
        .glassSheen(intensity: 0.12, spread: 0.70),
      ],
      isFullArt: true
    )
  }

  /// Milky opaque ceramic with a soft iridescent glaze.
  static var pearlCeramic: CardFinish {
    CardFinish(
      cardEffects: [
        .pearlCeramic(intensity: 0.84),
        .chromaticGlass(intensity: 0.14, separation: 0.18),
      ],
      isFullArt: true
    )
  }

  /// Dark polished metal with fluid rainbow interference.
  static var oilSlick: CardFinish {
    CardFinish(
      cardEffects: [
        .oilSlick(intensity: 0.88),
        .glassSheen(intensity: 0.12, spread: 0.48),
      ],
      isFullArt: true
    )
  }
}
