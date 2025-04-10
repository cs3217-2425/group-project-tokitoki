//
//  CodableModels.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 10/4/25.
//



import Foundation

// MARK: - Player Codable Model

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
    
    // Convert to domain model (partial - needs to be completed with Tokis, Skills, Equipment)
    func toDomainModel() -> Player {
        return Player(
            id: UUID(uuidString: id.uuidString) ?? UUID(),
            name: name,
            level: level,
            experience: experience,
            currency: currency,
            statistics: Player.PlayerStatistics(
                totalBattles: statistics.totalBattles,
                battlesWon: statistics.battlesWon
            ),
            lastLoginDate: lastLoginDate,
            ownedTokis: [], // Will be populated separately
            ownedSkills: [], // Will be populated separately
            ownedEquipments: EquipmentComponent(), // Will be populated separately
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
        self.id = UUID(uuidString: toki.id.uuidString) ?? UUID()
        self.name = toki.name
        self.level = toki.level
        self.rarity = toki.rarity.value
        self.elementType = toki.elementType.map { $0.rawValue }
        self.ownerId = UUID(uuidString: ownerId.uuidString) ?? UUID()
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
        self.skillNames = toki.skills.map { $0.name }
        self.equipmentIds = toki.equipments.map { $0.id }
    }
    
    // Convert to domain model (partial - needs skills and equipment to be added)
    func toDomainModel() -> Toki {
        let elementTypes = elementType.compactMap { ElementType(rawValue: $0) }
        return Toki(
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
            skills: [], // Will be populated from skillNames
            equipments: [], // Will be populated from equipmentIds
            elementType: elementTypes,
            level: level
        )
    }
}

// MARK: - Equipment Codable Models

// Base Equipment Codable
protocol EquipmentCodable: Codable {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var rarity: Int { get }
    var equipmentType: String { get }
    var ownerId: UUID { get }
    
    func toDomainModel() -> Equipment
}

// Non-Consumable Equipment Codable
struct NonConsumableEquipmentCodable: EquipmentCodable {
    let id: UUID
    let name: String
    let description: String
    let rarity: Int
    let equipmentType: String = "nonConsumable"
    let ownerId: UUID
    let isEquipped: Bool
    let slot: String
    let buffValue: Int
    let buffDescription: String
    let affectedStat: String
    
    // Convert from domain model
    init(from equipment: NonConsumableEquipment, ownerId: UUID, isEquipped: Bool) {
        self.id = UUID(uuidString: equipment.id.uuidString) ?? UUID()
        self.name = equipment.name
        self.description = equipment.description
        self.rarity = equipment.rarity
        self.ownerId = ownerId
        self.isEquipped = isEquipped
        self.slot = equipment.slot.rawValue
        self.buffValue = equipment.buff.value
        self.buffDescription = equipment.buff.description
        self.affectedStat = equipment.buff.affectedStat
    }
    
    // Convert to domain model
    func toDomainModel() -> Equipment {
        let buff = EquipmentBuff(
            value: buffValue,
            description: buffDescription,
            affectedStat: affectedStat
        )
        
        let slot = EquipmentSlot(rawValue: self.slot) ?? .weapon
        
        return NonConsumableEquipment(
            name: name,
            description: description,
            rarity: rarity,
            buff: buff,
            slot: slot
        )
    }
}

// Potion Equipment Codable
struct PotionEquipmentCodable: EquipmentCodable {
    let id: UUID
    let name: String
    let description: String
    let rarity: Int
    let equipmentType: String = "consumable"
    let ownerId: UUID
    let consumableType: String = "potion"
    let usageContext: String
    
    // Convert from domain model
    init(from potion: Potion, ownerId: UUID) {
        self.id = UUID(uuidString: potion.id.uuidString) ?? UUID()
        self.name = potion.name
        self.description = potion.description
        self.rarity = potion.rarity
        self.ownerId = ownerId
        self.usageContext = consumableUsageContextToString(potion.usageContext)
    }
    
    // Convert to domain model
    func toDomainModel() -> Equipment {
        // Since we can't reconstruct the effect calculators, we'll create a basic potion
        return Potion(
            name: name,
            description: description,
            rarity: rarity,
            effectCalculators: []
        )
    }
}

// Candy Equipment Codable
struct CandyEquipmentCodable: EquipmentCodable {
    let id: UUID
    let name: String
    let description: String
    let rarity: Int
    let equipmentType: String = "consumable"
    let ownerId: UUID
    let consumableType: String = "candy"
    let bonusExp: Int
    let usageContext: String
    
    // Convert from domain model
    init(from candy: Candy, ownerId: UUID) {
        self.id = UUID(uuidString: candy.id.uuidString) ?? UUID()
        self.name = candy.name
        self.description = candy.description
        self.rarity = candy.rarity
        self.ownerId = ownerId
        self.bonusExp = candy.bonusExp
        self.usageContext = consumableUsageContextToString(candy.usageContext)
    }
    
    // Convert to domain model
    func toDomainModel() -> Equipment {
        return Candy(
            name: name,
            description: description,
            rarity: rarity,
            bonusExp: bonusExp
        )
    }
}



// MARK: - Helper Functions

// Convert ConsumableUsageContext to string
func consumableUsageContextToString(_ context: ConsumableUsageContext) -> String {
    switch context {
    case .battleOnly: return "battleOnly"
    case .outOfBattleOnly: return "outOfBattleOnly"
    case .anywhere: return "anywhere"
    }
}

// Convert string to ConsumableUsageContext
func stringToConsumableUsageContext(_ string: String) -> ConsumableUsageContext {
    switch string.lowercased() {
    case "battleonly": return .battleOnly
    case "outofbattleonly": return .outOfBattleOnly
    case "anywhere": return .anywhere
    default: return .battleOnly
    }
}

// MARK: - Codable Equipment Container

// Special struct for encoding/decoding equipment arrays that can contain different equipment types
struct EquipmentContainer: Codable {
    var equipments: [AnyEquipment]
    
    init(equipments: [AnyEquipment]) {
        self.equipments = equipments
    }
    
    // Custom encoding logic
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for anyEquipment in equipments {
            try container.encode(anyEquipment)
        }
    }
    
    // Custom decoding logic
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var equipments: [AnyEquipment] = []
        
        while !container.isAtEnd {
            let equipment = try container.decode(AnyEquipment.self)
            equipments.append(equipment)
        }
        
        self.equipments = equipments
    }
    
    // Initialize from domain equipment array
    init(from domainEquipments: [Equipment], ownerId: UUID, equipped: [EquipmentSlot: NonConsumableEquipment] = [:]) {
        self.equipments = []
        
        // Add inventory items
        for equipment in domainEquipments {
            let isEquipped = equipped.values.contains { $0.id == equipment.id }
            if let nonConsumable = equipment as? NonConsumableEquipment {
                let codable = NonConsumableEquipmentCodable(from: nonConsumable, ownerId: ownerId, isEquipped: isEquipped)
                self.equipments.append(AnyEquipment(nonConsumable: codable))
            } else if let potion = equipment as? Potion {
                let codable = PotionEquipmentCodable(from: potion, ownerId: ownerId)
                self.equipments.append(AnyEquipment(potion: codable))
            } else if let candy = equipment as? Candy {
                let codable = CandyEquipmentCodable(from: candy, ownerId: ownerId)
                self.equipments.append(AnyEquipment(candy: codable))
            }
        }
        
        // Add equipped items that might not be in the inventory
        for (_, equipment) in equipped {
            let alreadyIncluded = self.equipments.contains {
                if case let .nonConsumable(nonConsumable) = $0.equipment, nonConsumable.id == equipment.id {
                    return true
                }
                return false
            }
            
            if !alreadyIncluded {
                let codable = NonConsumableEquipmentCodable(from: equipment, ownerId: ownerId, isEquipped: true)
                self.equipments.append(AnyEquipment(nonConsumable: codable))
            }
        }
    }
}

// Type-erased equipment to handle polymorphic encoding/decoding
struct AnyEquipment: Codable {
    enum EquipmentType: String, Codable {
        case nonConsumable
        case potion
        case candy
    }
    
    let equipment: Equipment
    
    enum CodingKeys: String, CodingKey {
        case type, equipment
    }
    
    init(nonConsumable: NonConsumableEquipmentCodable) {
        self.equipment = .nonConsumable(nonConsumable)
    }
    
    init(potion: PotionEquipmentCodable) {
        self.equipment = .potion(potion)
    }
    
    init(candy: CandyEquipmentCodable) {
        self.equipment = .candy(candy)
    }
    
    // Custom encoding logic
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch equipment {
        case .nonConsumable(let value):
            try container.encode(EquipmentType.nonConsumable, forKey: .type)
            try container.encode(value, forKey: .equipment)
        case .potion(let value):
            try container.encode(EquipmentType.potion, forKey: .type)
            try container.encode(value, forKey: .equipment)
        case .candy(let value):
            try container.encode(EquipmentType.candy, forKey: .type)
            try container.encode(value, forKey: .equipment)
        }
    }
    
    // Custom decoding logic
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(EquipmentType.self, forKey: .type)
        
        switch type {
        case .nonConsumable:
            let value = try container.decode(NonConsumableEquipmentCodable.self, forKey: .equipment)
            self.equipment = .nonConsumable(value)
        case .potion:
            let value = try container.decode(PotionEquipmentCodable.self, forKey: .equipment)
            self.equipment = .potion(value)
        case .candy:
            let value = try container.decode(CandyEquipmentCodable.self, forKey: .equipment)
            self.equipment = .candy(value)
        }
    }
    
    // Helper for typed equipment access
    enum Equipment {
        case nonConsumable(NonConsumableEquipmentCodable)
        case potion(PotionEquipmentCodable)
        case candy(CandyEquipmentCodable)
    }
}
