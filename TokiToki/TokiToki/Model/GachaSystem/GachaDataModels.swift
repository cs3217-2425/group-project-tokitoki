//
//  GachaDataModels.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//


struct EquipmentsData: Codable {
    let equipment: [EquipmentData]
}

// Data model for event configuration
struct EventData: Codable {
    let name: String              // Used as the unique identifier
    let description: String
    let startDate: String         // ISO format
    let endDate: String           // ISO format
    let eventType: String
    let targetElement: String?
    let targetRarity: String?
    let targetItemNames: [String]?  // Changed from targetItemIds
    let rateMultiplier: Double
}

struct EventsData: Codable {
    let events: [EventData]
}

// Toki Data for loading from JSON
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
}

struct TokisData: Codable {
    let tokis: [TokiData]
}

// Skill Data for loading from JSON
struct SkillData: Codable {
    let id: String
    let name: String
    let description: String
    let rarity: Int
    let skillType: String
    let targetType: String
    let elementType: String
    let basePower: Int
    let cooldown: Int
    let statusEffectChance: Double?
    let statusEffect: String?
    let statusEffectDuration: Int?
}

struct SkillsData: Codable {
    let skills: [SkillData]
}


// Gacha Item Data within a pack
struct GachaItemData: Codable {
    let itemId: String
    let itemType: String // "toki", "skill", "equipment"
    let baseRate: Double // Base probability (0.0 to 1.0)
    let rarity: Int?
    let elementType: String?
}


// Gacha Pack Data for loading from JSON
struct GachaPackData: Codable {
    let packName: String
    let description: String
    let cost: Int
    let items: [GachaItemData]
}

struct GachaPacksData: Codable {
    let packs: [GachaPackData]
}


// Gacha Pack
struct GachaPack{
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

// Equipment Data for loading from JSON
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
        let affectedStat: String
    }
    
    struct EffectStrategyData: Codable {
        let type: String          // "healing", "potion", "upgradeCandy", etc.
        
        // For healing effects
        let healAmount: Int?
        
        // For potion effects
        let buffValue: Int?
        let duration: Double?
        let statType: String?
        
        // For upgrade candy effects
        let bonusExp: Int?
    }
}


