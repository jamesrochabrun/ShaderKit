//
//  CardLibrary.swift
//  ShaderCards
//
//  The preset card library: every creature, trainer, and energy card
//  that ships with the package.
//

import Foundation

/// The built-in card library.
///
/// Access individual presets (`CardLibrary.emberfox`), themed collections
/// (`CardLibrary.fireCards`), or everything at once (`CardLibrary.allCards`).
public enum CardLibrary {

  // MARK: - Collections

  /// Every card in the library, in set-number order.
  public static var allCards: [Card] {
    creatureCards + trainerCards + energyCards + specialEditionCards + cssParityCards
  }

  /// All creature cards.
  public static var creatureCards: [Card] {
    creatures.map { .creature($0) }
  }

  /// All trainer cards.
  public static var trainerCards: [Card] {
    trainers.map { .trainer($0) }
  }

  /// All energy cards (11 basic + specials).
  public static var energyCards: [Card] {
    energies.map { .energy($0) }
  }

  /// Creature cards for one element.
  public static func cards(for element: ElementType) -> [Card] {
    creatures.filter { $0.element == element }.map { .creature($0) }
  }

  /// Cards of a given rarity.
  public static func cards(of rarity: CardRarity) -> [Card] {
    allCards.filter { $0.rarity == rarity }
  }

  /// A curated showcase: one spectacular card per holo treatment,
  /// ideal for demo reels.
  public static var showcase: [Card] {
    [
      .creature(emberfox),        // holo rare
      .creature(mistjelly),       // reverse holo
      .creature(pyroclaw),        // double rare ex
      .creature(tidecaller),      // ultra rare full art
      .creature(thornsprite),     // illustration rare
      .creature(mindmoth),        // special illustration rare
      .creature(glimmerkit),      // rainbow rare
      .creature(nightfang),       // hyper rare gold
      .creature(dreamwisp),       // radiant
      .creature(voltkit),         // amazing rare
    ]
  }

  static let creatures: [CardModel] = [
    // MARK: Fire
    emberfox, pyroclaw, cindermoth,
    // MARK: Water
    aquafin, tidecaller, mistjelly,
    // MARK: Grass
    verdantail, bloomshell, thornsprite,
    // MARK: Lightning
    voltkit, stormbeak, zapwisp,
    // MARK: Psychic
    mindmoth, dreamwisp, astracat,
    // MARK: Fighting
    boulderfist, ridgewolf, cragturtle,
    // MARK: Darkness
    nightfang, shadewisp, duskraven,
    // MARK: Metal
    ironshell, chromehawk, forgegolem,
    // MARK: Fairy
    glimmerkit, pixiewing, starkitten,
    // MARK: Dragon
    auridrake, wyrmcoil, skyserpent,
    // MARK: Colorless
    nimbuff, skydancer, prismpaw,
  ]

  // MARK: - Fire

  public static let emberfox = CardModel(
    name: "Emberfox",
    element: .fire,
    hp: 120,
    stage: .stage1,
    rarity: .holoRare,
    artwork: .emberfox,
    attacks: [
      CardAttack(cost: [.fire, .colorless], name: "Cinder Dash", damage: "50",
                 text: "If this card moved from the bench this turn, this attack does 30 more damage."),
      CardAttack(cost: [.fire, .fire, .colorless], name: "Nine-Tail Flare", damage: "110"),
    ],
    weakness: .water,
    retreatCost: 1,
    species: "Ember Fox",
    flavorText: "Its tail embers never cool. Villagers follow the warm glow home through winter storms.",
    setNumber: "001/151"
  )

  public static let pyroclaw = CardModel(
    name: "Pyroclaw",
    element: .fire,
    hp: 220,
    stage: .ex,
    rarity: .doubleRare,
    artwork: .pyroclaw,
    ability: CardAbility(
      name: "Molten Armor",
      text: "Prevent all effects of attacks from your opponent's cards done to this card."
    ),
    attacks: [
      CardAttack(cost: [.fire, .fire, .colorless], name: "Magma Rend", damage: "180",
                 text: "Discard 2 Energy from this card."),
    ],
    weakness: .water,
    retreatCost: 3,
    species: "Lava Drake",
    setNumber: "002/151"
  )

  public static let cindermoth = CardModel(
    name: "Cindermoth",
    element: .fire,
    hp: 70,
    rarity: .uncommon,
    artwork: .cindermoth,
    attacks: [
      CardAttack(cost: [.fire], name: "Ash Scatter", damage: "20",
                 text: "The Defending card is now Burned."),
    ],
    weakness: .water,
    retreatCost: 0,
    species: "Ash Moth",
    flavorText: "It rests inside chimneys by day and dances above bonfires at dusk.",
    setNumber: "003/151"
  )

  // MARK: - Water

  public static let aquafin = CardModel(
    name: "Aquafin",
    element: .water,
    hp: 60,
    rarity: .common,
    artwork: .aquafin,
    attacks: [
      CardAttack(cost: [.water], name: "Bubble Jet", damage: "20"),
    ],
    weakness: .lightning,
    retreatCost: 1,
    species: "River Koi",
    flavorText: "It leaps upstream waterfalls each spring, scattering rainbow spray as it climbs.",
    setNumber: "004/151"
  )

  public static let tidecaller = CardModel(
    name: "Tidecaller",
    element: .water,
    hp: 210,
    stage: .vStyle,
    rarity: .ultraRare,
    artwork: .tidecaller,
    attacks: [
      CardAttack(cost: [.water, .water], name: "Deep Current", damage: "90",
                 text: "Move an Energy from your opponent's Active card to their bench."),
      CardAttack(cost: [.water, .water, .colorless], name: "Tidal Crown", damage: "160"),
    ],
    weakness: .lightning,
    retreatCost: 2,
    species: "Sea Sovereign",
    setNumber: "005/151"
  )

  public static let mistjelly = CardModel(
    name: "Mistjelly",
    element: .water,
    hp: 80,
    rarity: .reverseHolo,
    artwork: .mistjelly,
    ability: CardAbility(
      name: "Fog Veil",
      text: "As long as this card is on your bench, it takes no damage from attacks."
    ),
    attacks: [
      CardAttack(cost: [.water, .colorless], name: "Drifting Sting", damage: "40"),
    ],
    weakness: .lightning,
    retreatCost: 1,
    species: "Mist Jelly",
    setNumber: "006/151"
  )

  // MARK: - Grass

  public static let verdantail = CardModel(
    name: "Verdantail",
    element: .grass,
    hp: 90,
    rarity: .rare,
    artwork: .verdantail,
    attacks: [
      CardAttack(cost: [.grass], name: "Leaf Flick", damage: "30"),
      CardAttack(cost: [.grass, .colorless], name: "Bloom Pounce", damage: "60",
                 text: "Heal 20 damage from this card."),
    ],
    weakness: .fire,
    resistance: .water,
    retreatCost: 1,
    species: "Garden Cat",
    flavorText: "Wherever it naps, wildflowers push up through the grass to shade its dreams.",
    setNumber: "007/151"
  )

  public static let bloomshell = CardModel(
    name: "Bloomshell",
    element: .grass,
    hp: 110,
    stage: .stage1,
    rarity: .uncommon,
    artwork: .bloomshell,
    attacks: [
      CardAttack(cost: [.grass, .colorless], name: "Petal Spin", damage: "50"),
      CardAttack(cost: [.grass, .grass, .colorless], name: "Garden Slam", damage: "90"),
    ],
    weakness: .fire,
    retreatCost: 3,
    species: "Blossom Turtle",
    setNumber: "008/151"
  )

  public static let thornsprite = CardModel(
    name: "Thornsprite",
    element: .grass,
    hp: 70,
    rarity: .illustrationRare,
    artwork: .thornsprite,
    attacks: [
      CardAttack(cost: [.grass], name: "Bramble Wisp", damage: "20",
                 text: "Your opponent's Active card is now Poisoned."),
    ],
    weakness: .fire,
    retreatCost: 1,
    species: "Thorn Spirit",
    flavorText: "Deep in bramble hollows it tends a single silver rose no one has ever seen bloom.",
    setNumber: "009/151"
  )

  // MARK: - Lightning

  public static let voltkit = CardModel(
    name: "Voltkit",
    element: .lightning,
    hp: 90,
    rarity: .amazing,
    artwork: .voltkit,
    attacks: [
      CardAttack(cost: [.lightning, .colorless], name: "Static Pounce", damage: "60",
                 text: "Flip a coin. If heads, the Defending card is now Paralyzed."),
    ],
    weakness: .fighting,
    retreatCost: 1,
    species: "Spark Kitten",
    flavorText: "Its fur crackles when storms approach. City rooftops are its playground.",
    setNumber: "010/151"
  )

  public static let stormbeak = CardModel(
    name: "Stormbeak",
    element: .lightning,
    hp: 130,
    stage: .stage1,
    rarity: .holoRare,
    artwork: .stormbeak,
    attacks: [
      CardAttack(cost: [.lightning, .lightning], name: "Thunder Dive", damage: "100",
                 text: "This card also does 20 damage to itself."),
    ],
    weakness: .fighting,
    resistance: .metal,
    retreatCost: 0,
    species: "Storm Raptor",
    setNumber: "011/151"
  )

  public static let zapwisp = CardModel(
    name: "Zapwisp",
    element: .lightning,
    hp: 50,
    rarity: .common,
    artwork: .zapwisp,
    attacks: [
      CardAttack(cost: [.lightning], name: "Jolt", damage: "10",
                 text: "Search your deck for a Lightning Energy and attach it to this card."),
    ],
    weakness: .fighting,
    retreatCost: 0,
    species: "Static Wisp",
    flavorText: "Born from the last flicker of a lightning strike, it hums a tiny electric song.",
    setNumber: "012/151"
  )

  // MARK: - Psychic

  public static let mindmoth = CardModel(
    name: "Mindmoth",
    element: .psychic,
    hp: 140,
    stage: .stage2,
    rarity: .specialIllustrationRare,
    artwork: .mindmoth,
    ability: CardAbility(
      name: "Dream Dust",
      text: "Once during your turn, you may put your opponent's Active card to Sleep."
    ),
    attacks: [
      CardAttack(cost: [.psychic, .colorless], name: "Lunar Beam", damage: "80"),
    ],
    weakness: .darkness,
    resistance: .fighting,
    retreatCost: 1,
    species: "Dream Moth",
    setNumber: "013/151"
  )

  public static let dreamwisp = CardModel(
    name: "Dreamwisp",
    element: .psychic,
    hp: 80,
    rarity: .radiant,
    artwork: .dreamwisp,
    attacks: [
      CardAttack(cost: [.psychic], name: "Sleepy Spiral", damage: "30",
                 text: "Both Active cards are now Asleep."),
    ],
    weakness: .darkness,
    retreatCost: 1,
    species: "Dream Spirit",
    flavorText: "It gathers stray nightmares and spins them into harmless silver threads.",
    setNumber: "014/151"
  )

  public static let astracat = CardModel(
    name: "Astracat",
    element: .psychic,
    hp: 100,
    stage: .stage1,
    rarity: .rare,
    artwork: .astracat,
    attacks: [
      CardAttack(cost: [.psychic, .colorless], name: "Comet Claw", damage: "50"),
      CardAttack(cost: [.psychic, .psychic], name: "Constellation", damage: "40×",
                 text: "This attack does 40 damage for each Energy attached to this card."),
    ],
    weakness: .darkness,
    resistance: .fighting,
    retreatCost: 1,
    species: "Astral Cat",
    setNumber: "015/151"
  )

  // MARK: - Fighting

  public static let boulderfist = CardModel(
    name: "Boulderfist",
    element: .fighting,
    hp: 240,
    stage: .ex,
    rarity: .doubleRare,
    artwork: .boulderfist,
    attacks: [
      CardAttack(cost: [.fighting, .fighting], name: "Landslide Punch", damage: "120"),
      CardAttack(cost: [.fighting, .fighting, .colorless], name: "Tectonic Slam", damage: "210",
                 text: "This card can't attack during your next turn."),
    ],
    weakness: .grass,
    retreatCost: 4,
    species: "Mountain Golem",
    setNumber: "016/151"
  )

  public static let ridgewolf = CardModel(
    name: "Ridgewolf",
    element: .fighting,
    hp: 110,
    stage: .stage1,
    rarity: .uncommon,
    artwork: .ridgewolf,
    attacks: [
      CardAttack(cost: [.fighting], name: "Canyon Howl", damage: "",
                 text: "Attach a Fighting Energy from your discard pile to each of your benched cards."),
      CardAttack(cost: [.fighting, .colorless], name: "Cliff Dive", damage: "70"),
    ],
    weakness: .psychic,
    retreatCost: 2,
    species: "Ridge Wolf",
    setNumber: "017/151"
  )

  public static let cragturtle = CardModel(
    name: "Cragturtle",
    element: .fighting,
    hp: 100,
    rarity: .common,
    artwork: .cragturtle,
    attacks: [
      CardAttack(cost: [.fighting, .colorless], name: "Rock Withdraw", damage: "30",
                 text: "During your opponent's next turn, this card takes 30 less damage."),
    ],
    weakness: .grass,
    retreatCost: 3,
    species: "Crag Turtle",
    flavorText: "Desert travelers mistake its mossy shell for a boulder and camp in its shade.",
    setNumber: "018/151"
  )

  // MARK: - Darkness

  public static let nightfang = CardModel(
    name: "Nightfang",
    element: .darkness,
    hp: 230,
    stage: .ex,
    rarity: .hyperRare,
    artwork: .nightfang,
    ability: CardAbility(
      name: "Moonless Hunt",
      text: "Once during your turn, you may move a Darkness Energy from your bench to this card."
    ),
    attacks: [
      CardAttack(cost: [.darkness, .darkness, .colorless], name: "Eclipse Fang", damage: "190"),
    ],
    weakness: .grass,
    retreatCost: 2,
    species: "Shadow Wolf",
    setNumber: "019/151"
  )

  public static let shadewisp = CardModel(
    name: "Shadewisp",
    element: .darkness,
    hp: 60,
    rarity: .reverseHolo,
    artwork: .shadewisp,
    attacks: [
      CardAttack(cost: [.darkness], name: "Dim Flicker", damage: "20",
                 text: "Put a card from your opponent's discard pile on the bottom of their deck."),
    ],
    weakness: .fighting,
    retreatCost: 1,
    species: "Gloom Wisp",
    flavorText: "Streetlamps dim one by one as it drifts past, collecting borrowed light.",
    setNumber: "020/151"
  )

  public static let duskraven = CardModel(
    name: "Duskraven",
    element: .darkness,
    hp: 110,
    stage: .stage1,
    rarity: .rare,
    artwork: .duskraven,
    attacks: [
      CardAttack(cost: [.darkness, .colorless], name: "Twilight Talon", damage: "60"),
      CardAttack(cost: [.darkness, .darkness], name: "Night Heist", damage: "40",
                 text: "Your opponent reveals their hand. Discard an Item card you find there."),
    ],
    weakness: .lightning,
    resistance: .fighting,
    retreatCost: 1,
    species: "Dusk Raven",
    setNumber: "021/151"
  )

  // MARK: - Metal

  public static let ironshell = CardModel(
    name: "Ironshell",
    element: .metal,
    hp: 140,
    stage: .stage1,
    rarity: .holoRare,
    artwork: .ironshell,
    attacks: [
      CardAttack(cost: [.metal, .colorless], name: "Alloy Guard", damage: "40",
                 text: "During your opponent's next turn, this card takes 40 less damage."),
      CardAttack(cost: [.metal, .metal, .colorless], name: "Anvil Drop", damage: "120"),
    ],
    weakness: .fire,
    resistance: .grass,
    retreatCost: 4,
    species: "Iron Turtle",
    setNumber: "022/151"
  )

  public static let chromehawk = CardModel(
    name: "Chromehawk",
    element: .metal,
    hp: 100,
    rarity: .uncommon,
    artwork: .chromehawk,
    attacks: [
      CardAttack(cost: [.metal], name: "Mirror Wing", damage: "30",
                 text: "If this card has full HP, this attack does 30 more damage."),
    ],
    weakness: .fire,
    resistance: .grass,
    retreatCost: 1,
    species: "Chrome Hawk",
    flavorText: "Its polished feathers reflect the sky so perfectly that radar can't find it.",
    setNumber: "023/151"
  )

  public static let forgegolem = CardModel(
    name: "Forgegolem",
    element: .metal,
    hp: 250,
    stage: .ex,
    rarity: .doubleRare,
    artwork: .forgegolem,
    attacks: [
      CardAttack(cost: [.metal, .metal], name: "Furnace Fist", damage: "100",
                 text: "This attack's damage isn't affected by Resistance."),
      CardAttack(cost: [.metal, .metal, .metal], name: "Foundry Crash", damage: "220",
                 text: "Discard an Energy from this card."),
    ],
    weakness: .fire,
    resistance: .grass,
    retreatCost: 4,
    species: "Forge Golem",
    setNumber: "024/151"
  )

  // MARK: - Fairy

  public static let glimmerkit = CardModel(
    name: "Glimmerkit",
    element: .fairy,
    hp: 190,
    stage: .vStyle,
    rarity: .rainbowRare,
    artwork: .glimmerkit,
    attacks: [
      CardAttack(cost: [.fairy], name: "Twinkle Step", damage: "30",
                 text: "During your opponent's next turn, this card evades attacks on a coin flip of heads."),
      CardAttack(cost: [.fairy, .fairy, .colorless], name: "Prism Burst", damage: "150"),
    ],
    weakness: .metal,
    resistance: .darkness,
    retreatCost: 1,
    species: "Glimmer Fox",
    setNumber: "025/151"
  )

  public static let pixiewing = CardModel(
    name: "Pixiewing",
    element: .fairy,
    hp: 80,
    rarity: .holoRare,
    artwork: .pixiewing,
    attacks: [
      CardAttack(cost: [.fairy], name: "Pixie Dust", damage: "20",
                 text: "Heal 20 damage from each of your benched cards."),
    ],
    weakness: .metal,
    resistance: .darkness,
    retreatCost: 0,
    species: "Pixie Moth",
    flavorText: "Moonlit meadows sparkle where it has passed, and wishes made there come true more often.",
    setNumber: "026/151"
  )

  public static let starkitten = CardModel(
    name: "Starkitten",
    element: .fairy,
    hp: 60,
    rarity: .common,
    artwork: .starkitten,
    attacks: [
      CardAttack(cost: [.fairy], name: "Star Swat", damage: "20"),
    ],
    weakness: .metal,
    retreatCost: 1,
    species: "Star Kitten",
    flavorText: "It bats fallen stars across the night sky and chases them back down again.",
    setNumber: "027/151"
  )

  // MARK: - Dragon

  public static let auridrake = CardModel(
    name: "Auridrake",
    element: .dragon,
    hp: 280,
    stage: .vMax,
    rarity: .specialIllustrationRare,
    artwork: .auridrake,
    attacks: [
      CardAttack(cost: [.fire, .water], name: "Gilded Breath", damage: "130"),
      CardAttack(cost: [.fire, .water, .colorless], name: "Sovereign Storm", damage: "240",
                 text: "This card can't use Sovereign Storm during your next turn."),
    ],
    retreatCost: 3,
    species: "Gilded Dragon",
    setNumber: "028/151"
  )

  public static let wyrmcoil = CardModel(
    name: "Wyrmcoil",
    element: .dragon,
    hp: 200,
    stage: .vStyle,
    rarity: .ultraRare,
    artwork: .wyrmcoil,
    attacks: [
      CardAttack(cost: [.grass, .lightning], name: "Verdant Coil", damage: "80",
                 text: "Attach up to 2 Energy from your hand to your benched cards."),
      CardAttack(cost: [.grass, .lightning, .colorless], name: "Jade Cyclone", damage: "170"),
    ],
    retreatCost: 2,
    species: "Jade Wyrm",
    setNumber: "029/151"
  )

  public static let skyserpent = CardModel(
    name: "Skyserpent",
    element: .dragon,
    hp: 120,
    rarity: .radiant,
    artwork: .skyserpent,
    attacks: [
      CardAttack(cost: [.water, .lightning], name: "Aurora Ribbon", damage: "70",
                 text: "This attack's damage isn't affected by Weakness or Resistance."),
    ],
    retreatCost: 1,
    species: "Cloud Serpent",
    flavorText: "Sailors say the first rainbow after a storm is Skyserpent heading home.",
    setNumber: "030/151"
  )

  // MARK: - Colorless

  public static let nimbuff = CardModel(
    name: "Nimbuff",
    element: .colorless,
    hp: 70,
    rarity: .common,
    artwork: .nimbuff,
    attacks: [
      CardAttack(cost: [.colorless], name: "Fluff Tackle", damage: "20"),
      CardAttack(cost: [.colorless, .colorless], name: "Cloud Nap", damage: "",
                 text: "Heal 40 damage from this card. This card is now Asleep."),
    ],
    weakness: .lightning,
    retreatCost: 1,
    species: "Cloud Puff",
    flavorText: "On lazy afternoons whole flocks of them drift by, indistinguishable from cumulus.",
    setNumber: "031/151"
  )

  public static let skydancer = CardModel(
    name: "Skydancer",
    element: .colorless,
    hp: 110,
    stage: .stage1,
    rarity: .illustrationRare,
    artwork: .skydancer,
    attacks: [
      CardAttack(cost: [.colorless, .colorless], name: "Aerial Waltz", damage: "60",
                 text: "Switch this card with one of your benched cards."),
    ],
    weakness: .lightning,
    resistance: .fighting,
    retreatCost: 0,
    species: "Wind Dancer",
    setNumber: "032/151"
  )

  public static let prismpaw = CardModel(
    name: "Prismpaw",
    element: .colorless,
    hp: 90,
    rarity: .amazing,
    artwork: .prismpaw,
    ability: CardAbility(
      name: "Prism Coat",
      text: "This card's type is every type at once. Apply Weakness for all types."
    ),
    attacks: [
      CardAttack(cost: [.colorless, .colorless], name: "Refraction", damage: "50"),
    ],
    retreatCost: 1,
    species: "Prism Cat",
    setNumber: "033/151"
  )

  // MARK: - Trainers

  public static let healingPotion = TrainerCardModel(
    name: "Healing Potion",
    kind: .item,
    rarity: .common,
    text: "Heal 30 damage from one of your cards.",
    artwork: .potion,
    setNumber: "034/151"
  )

  public static let professorHazel = TrainerCardModel(
    name: "Professor Hazel",
    kind: .supporter,
    rarity: .uncommon,
    text: "Discard your hand and draw 7 cards.",
    artwork: .researchLab,
    setNumber: "035/151"
  )

  public static let expeditionMap = TrainerCardModel(
    name: "Expedition Map",
    kind: .item,
    rarity: .common,
    text: "Search your deck for any card, reveal it, and put it into your hand. Shuffle your deck afterward.",
    artwork: .travelMap,
    setNumber: "036/151"
  )

  public static let summitArena = TrainerCardModel(
    name: "Summit Arena",
    kind: .stadium,
    rarity: .uncommon,
    text: "Attacks of Fighting cards in play (both yours and your opponent's) do 20 more damage.",
    artwork: .trainingGrounds,
    setNumber: "037/151"
  )

  public static let crystalCavern = TrainerCardModel(
    name: "Crystal Cavern",
    kind: .stadium,
    rarity: .rare,
    text: "Once during each player's turn, that player may heal 20 damage from their Active card.",
    artwork: .crystalCavern,
    setNumber: "038/151"
  )

  public static let nightTrader = TrainerCardModel(
    name: "Night Trader",
    kind: .supporter,
    rarity: .rare,
    text: "Trade a card from your hand for the top card of your deck. If it's an Energy, attach it to a card of your choice.",
    artwork: .midnightMarket,
    setNumber: "039/151"
  )

  static let trainers: [TrainerCardModel] = [
    healingPotion, professorHazel, expeditionMap,
    summitArena, crystalCavern, nightTrader,
  ]

  // MARK: - Energy

  static let energies: [EnergyCardModel] = basicEnergies + specialEnergies

  /// One basic energy card per element.
  public static let basicEnergies: [EnergyCardModel] = ElementType.allCases.enumerated().map { index, element in
    EnergyCardModel(
      element: element,
      setNumber: String(format: "%03d/151", 40 + index)
    )
  }

  /// Holo special energies.
  public static let specialEnergies: [EnergyCardModel] = [
    EnergyCardModel(element: .dragon, isSpecial: true, setNumber: "051/151"),
    EnergyCardModel(element: .darkness, isSpecial: true, setNumber: "052/151"),
  ]
}
