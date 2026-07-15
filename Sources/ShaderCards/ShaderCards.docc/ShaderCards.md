# ``ShaderCards``

Holographic trading cards for SwiftUI, rendered entirely from code.

## Overview

ShaderCards renders Pokémon-style trading cards with procedural SwiftUI
artwork and real-time Metal foil effects from ShaderKit. Present a card
from the built-in library, compose your own with ``CardBuilder``, or let
users design cards interactively in ``CardStudioView``.

```swift
import ShaderCards

TradingCardView(.creature(CardLibrary.emberfox), width: 300)
```

## Topics

### Presenting cards

- ``TradingCardView``
- ``CardFaceView``
- ``CardGalleryView``
- ``ExplodableCardView``
- ``CardStudioView``

### The card library

- ``CardLibrary``
- ``CardArtwork``
- ``ArtworkView``

### Card data

- ``Card``
- ``CardModel``
- ``CardArt``
- ``CardArtView``
- ``TrainerCardModel``
- ``EnergyCardModel``
- ``CardAttack``
- ``CardAbility``
- ``CardStage``
- ``CardLayout``
- ``TrainerKind``

### Building custom cards

- ``CardBuilder``

### Design system

- ``ElementType``
- ``ElementPalette``
- ``CardRarity``
- ``CardFinish``
- ``CardMetrics``
- ``EnergyIcon``
