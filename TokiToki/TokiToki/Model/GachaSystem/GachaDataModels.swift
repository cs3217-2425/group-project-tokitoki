//
//  GachaDataModels.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//

struct EquipmentsData: Codable {
    let equipment: [EquipmentData]
}

struct EventData: Codable {
    let name: String
    let description: String
    let startDate: String
    let endDate: String
    let eventType: String
    let targetElement: String?
    let targetRarity: String?
    let targetItemNames: [String]?
    let rateMultiplier: Double
}

struct EventsData: Codable {
    let events: [EventData]
}

struct TokiData: Codable {
    let id: String
    let name: String
    let rarity: Int
    let baseHealth: Int
    let baseAttack: Int
    let baseDefense: Int
    let baseSpeed: Int
    let baseHeal: Int
    let baseExp: Int
    let elementType: String
    let skills: [String]
}

struct TokisData: Codable {
    let tokis: [TokiData]
}

struct SkillData: Codable {
    let id: String
    let name: String
    let description: String
    let cooldown: Int
    let effectDefinitions: [EffectDefinitionData]
}

struct EffectDefinitionData: Codable {
    let targetType: String
    let calculators: [CalculatorData]
}

struct CalculatorData: Codable {
    let calculatorType: String

    // Attack calculator fields
    let elementType: String?
    let basePower: Int?

    // Status effect calculator fields
    let statusEffectChance: Double?
    let statusEffect: String?
    let statusEffectDuration: Int?
    let statusEffectStrength: Double?

    // Stats modifier calculator fields
    let statsModifierDuration: Int?
    let attackModifier: Double?
    let defenseModifier: Double?
    let speedModifier: Double?
    let healModifier: Double?
    let critChanceModifier: Double?
    let critDmgModifier: Double?

    let healPower: Int?
}

struct SkillsData: Codable {
    let skills: [SkillData]
}

struct GachaItemData: Codable {
    let itemId: String
    let itemType: String // "toki", "equipment"
    let baseRate: Double // Base probability (0.0 to 1.0)
    let rarity: Int?
    let elementType: String?
}

struct GachaPackData: Codable {
    let packName: String
    let description: String
    let cost: Int
    let items: [GachaItemData]
}

struct GachaPacksData: Codable {
    let packs: [GachaPackData]
}

struct GachaPack {
    let name: String
    let description: String
    let cost: Int
    let items: [GachaPackItem]
}

struct GachaPackItem {
    let item: any IGachaItem
    let itemName: String
    let baseRate: Double
}

struct EquipmentData: Codable {
    let id: String
    let name: String
    let description: String
    let equipmentType: String    // "consumable" or "nonConsumable"
    let rarity: Int
    let elementType: String
    let buff: BuffData?          // Optional because consumables might not have buffs
    let slot: String?            // Optional because consumables don't have slots
    let effectStrategy: EffectStrategyData?  // Optional because nonConsumables don't have effects

    let inBattleOnly: Bool? // Optional -> Null = Anywhere, False = Outside, True = InBattle

    struct BuffData: Codable {
        let value: Int
        let description: String
        let affectedStats: [String]
    }
}

struct EffectStrategyData: Codable {
    let type: String
    let effectCalculators: [CalculatorData]? // for potions / mixed effects
    let healAmount: Int?              // convenience for pure‑heal items
    let bonusExp: Int?                // for candies
}
