# Pokémon Cards CSS parity matrix

This catalog tracks visual parity with the 21 active treatment sheets in
[simeydotme/pokemon-cards-css](https://github.com/simeydotme/pokemon-cards-css).
The reference project is GPL-3.0. ShaderKit's implementation is an original,
procedural Metal recreation: it does not copy the reference CSS or ship its
raster foil, mask, grain, glitter, or card-image assets.

## Interaction mapping

| CSS signal | ShaderKit signal |
|---|---|
| `--pointer-x`, `--pointer-y` | normalized `ShaderContext.touchPosition` |
| `--background-x`, `--background-y` | pointer-derived parallax pan |
| `--pointer-from-center` | radial distance from the normalized pointer |
| `--rotate-x`, `--rotate-y` | `HolographicCardContainer` with `.surfacePointer` and a 14.3° edge limit |
| `--card-opacity` | intensity and pointer-distance response |
| image foil/mask textures | procedural noise, FBM, glitter, etching, geometry, and region-aware `CardFinish` layers |

## Style coverage

| Reference sheet | ShaderKit style | ShaderCards placement |
|---|---|---|
| `regular-holo.css` | `regularHolo` | artwork window |
| `cosmos-holo.css` | `cosmosHolo` | artwork window |
| `reverse-holo.css` | `reverseHolo` | frame, excluding artwork |
| `radiant-holo.css` | `radiantHolo` | artwork plus lower-intensity frame lattice |
| `amazing-rare.css` | `amazingRare` | artwork window |
| `v-regular.css` | `vRegular` | full card |
| `v-max.css` | `vMax` | full card |
| `v-star.css` | `vStar` | full card |
| `v-full-art.css` | `vFullArt` | full card |
| `rainbow-holo.css` | `rainbowRare` | full card |
| `rainbow-alt.css` | `rainbowAlternate` | full card |
| `secret-rare.css` | `secretRareGold` | full card and gold frame |
| `shiny-rare.css` | `shinyRare` | artwork window |
| `shiny-v.css` | `shinyV` | full card |
| `shiny-vmax.css` | `shinyVMax` | full card |
| `trainer-full-art.css` | `trainerFullArt` | full trainer card |
| `trainer-gallery-holo.css` | `trainerGalleryHolo` | full trainer card |
| `trainer-gallery-secret-rare.css` | `trainerGallerySecretRare` | full trainer card and gold frame |
| `trainer-gallery-v-regular.css` | `trainerGalleryV` | full trainer card |
| `trainer-gallery-v-max.css` | `trainerGalleryVMax` | full trainer card |
| `swsh-pikachu.css` | `pikachuSecretRare` | full card |

`basic.css` intentionally has no foil treatment. `base.css` supplies shared
card mechanics rather than a separate finish, and maps to
`HolographicCardContainer` plus `ShaderContext`.

## Public API

```swift
CardFace()
  .tradingCardHolo(.vMax, intensity: 0.88)

TradingCardView(
  card,
  finish: .tradingCardHolo(.trainerGallerySecretRare)
)

CardLibrary.cssParityCards
```

ShaderCards uses the absolute surface pointer rather than accumulated drag
distance. Pressing at the card center is neutral, every edge maps to a clamped
normalized value of `1`, and the 3D rotation follows the same axis direction
and approximately `50 / 3.5` degree edge limit as the reference interaction.
