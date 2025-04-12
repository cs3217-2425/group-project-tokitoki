//
//  CodableModels.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 10/4/25.
//

import Foundation

struct PlayerCodable: Codable {
    let id: UUID
    var name: String
    var level: Int
    var experience: Int
    var currency: Int
    var pullsSinceRare: Int
    var dailyPullsCount: Int
    var lastLoginDate: Date
    var dailyPullsLastReset: Date?
    var statistics: StatisticsCodable
    
    struct StatisticsCodable: Codable {
        var totalBattles: Int
        var battlesWon: Int
    }
    
    // Convert from domain model
    init(from player: Player) {
        self.id = player.id
        self.name = player.name
        self.level = player.level
        self.experience = player.experience
        self.currency = player.currency
        self.pullsSinceRare = player.pullsSinceRare
        self.dailyPullsCount = player.dailyPullsCount
        self.lastLoginDate = player.lastLoginDate
        self.dailyPullsLastReset = player.dailyPullsLastReset
        self.statistics = StatisticsCodable(
            totalBattles: player.statistics.totalBattles,
            battlesWon: player.statistics.battlesWon
        )
    }
    
    // Convert to domain model (Tokis & Equipments are loaded separately)
    func toDomainModel() -> Player {
        Player(
            id: id,
            name: name,
            level: level,
            experience: experience,
            currency: currency,
            statistics: Player.PlayerStatistics(
                totalBattles: statistics.totalBattles,
                battlesWon: statistics.battlesWon
            ),
            lastLoginDate: lastLoginDate,
            ownedTokis: [],
            ownedSkills: [],
            ownedEquipments: EquipmentComponent(),
            pullsSinceRare: pullsSinceRare,
            dailyPullsCount: dailyPullsCount,
            dailyPullsLastReset: dailyPullsLastReset
        )
    }
}

// MARK: - Toki Codable Model

struct TokiCodable: Codable {
    let id: UUID
    var name: String
    var level: Int
    var rarity: Int
    var elementType: [String]
    var ownerId: UUID
    var baseStats: StatsCodable
    var skillNames: [String]
    var equipmentIds: [UUID]
    
    struct StatsCodable: Codable {
        var hp: Int
        var attack: Int
        var defense: Int
        var speed: Int
        var heal: Int
        var exp: Int
        var critHitChance: Int
        var critHitDamage: Int
    }
    
    // Convert from domain model
    init(from toki: Toki, ownerId: UUID) {
        self.id = toki.id
        self.name = toki.name
        self.level = toki.level
        self.rarity = toki.rarity.value
        self.elementType = toki.elementType.map { $0.rawValue }
        self.ownerId = ownerId
        self.baseStats = StatsCodable(
            hp: toki.baseStats.hp,
            attack: toki.baseStats.attack,
            defense: toki.baseStats.defense,
            speed: toki.baseStats.speed,
            heal: toki.baseStats.heal,
            exp: toki.baseStats.exp,
            critHitChance: toki.baseStats.critHitChance,
            critHitDamage: toki.baseStats.critHitDamage
        )
        self.skillNames = toki.skills.map { $0.name } // If you do Toki-level attachments
        self.equipmentIds = toki.equipments.map { $0.id } // If you do Toki-level attachments
    }
    
    // Convert to domain model (skills & real equipment are attached later)
    func toDomainModel() -> Toki {
        let elementTypes = elementType.compactMap { ElementType(rawValue: $0) }
        // Create a new Toki with freshly allocated arrays.
        let toki = Toki(
            id: id,
            name: name,
            rarity: ItemRarity(intValue: rarity) ?? .common,
            baseStats: TokiBaseStats(
                hp: baseStats.hp,
                attack: baseStats.attack,
                defense: baseStats.defense,
                speed: baseStats.speed,
                heal: baseStats.heal,
                exp: baseStats.exp,
                critHitChance: baseStats.critHitChance,
                critHitDamage: baseStats.critHitDamage
            ),
            skills: [],      // NEW: ensure a new, empty skills array
            equipments: [],  // NEW: ensure a new, empty equipments array
            elementType: elementTypes,
            level: level
        )
        return toki
    }
}

// MARK: - Equipment Codable Protocol

protocol EquipmentCodable: Codable {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var rarity: Int { get }
    var equipmentType: String { get }
    var ownerId: UUID { get }
    
    func toDomainModel() -> Equipment
}

// MARK: - Non-Consumable Equipment Codable

struct NonConsumableEquipmentCodable: EquipmentCodable {
    let id: UUID
    let name: String
    let description: String
    let rarity: Int
    let equipmentType: String  // Should be "nonConsumable"
    let ownerId: UUID
    
    let isEquipped: Bool
    let slot: String
    let buffValue: Int
    let buffDescription: String
    let affectedStat: String
    
    func toDomainModel() -> Equipment {
        let buff = EquipmentBuff(
            value: buffValue,
            description: buffDescription,
            affectedStat: affectedStat
        )
        let eqSlot = EquipmentSlot(rawValue: slot) ?? .weapon
        
        // NonConsumableEquipment’s real struct always generates a new ID internally:
        return NonConsumableEquipment(
            name: name,
            description: description,
            rarity: rarity,
            buff: buff,
            slot: eqSlot
        )
    }
}

// MARK: - Consumable Equipment Codable

struct ConsumableEquipmentCodable: EquipmentCodable {
    let id: UUID
    let name: String
    let description: String
    let rarity: Int
    let equipmentType: String  // "consumable"
    let ownerId: UUID
    
    let consumableType: String     // e.g., "potion" or "candy"
    let usageContext: String       // "battleOnly", etc.
    let bonusExp: Int?             // relevant for candy
    // Potentially more fields if needed (e.g., buffValue, etc.)
    
    func toDomainModel() -> Equipment {
        // Map usageContext from string
        let ctx: ConsumableUsageContext
        switch usageContext.lowercased() {
        case "battleonly":       ctx = .battleOnly
        case "outofbattleonly":  ctx = .outOfBattleOnly
        default:                 ctx = .anywhere
        }
        
        // Decide effect strategy
        if consumableType.lowercased() == "candy" {
            let expValue = bonusExp ?? 100
            return ConsumableEquipment(
                name: name,
                description: description,
                rarity: rarity,
                effectStrategy: UpgradeCandyEffectStrategy(bonusExp: expValue),
                usageContext: ctx
            )
        } else {
            // fallback "potion"
            return ConsumableEquipment(
                name: name,
                description: description,
                rarity: rarity,
                effectStrategy: PotionEffectStrategy(effectCalculators: [HealCalculator(healPower: 100)]),
                usageContext: ctx
            )
        }
    }
}

// MARK: - Type-erased equipment container (if you still need it)

enum AnyEquipment: Codable {
    case nonConsumable(NonConsumableEquipmentCodable)
    case consumable(ConsumableEquipmentCodable)
    
    enum CodingKeys: String, CodingKey {
        case type
        case payload
    }
    
    init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        let eqType     = try container.decode(String.self, forKey: .type)
        
        switch eqType {
        case "nonConsumable":
            let payload = try container.decode(NonConsumableEquipmentCodable.self, forKey: .payload)
            self = .nonConsumable(payload)
        case "consumable":
            let payload = try container.decode(ConsumableEquipmentCodable.self, forKey: .payload)
            self = .consumable(payload)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type,
                in: container,
                debugDescription: "Invalid equipment type: \(eqType)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .nonConsumable(let nc):
            try container.encode("nonConsumable", forKey: .type)
            try container.encode(nc, forKey: .payload)
        case .consumable(let c):
            try container.encode("consumable", forKey: .type)
            try container.encode(c, forKey: .payload)
        }
    }
    
    func toDomainModel() -> Equipment {
        switch self {
        case .nonConsumable(let nc):
            return nc.toDomainModel()
        case .consumable(let c):
            return c.toDomainModel()
        }
    }
}
