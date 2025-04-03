//
//  GachaItemAdapters.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 3/4/25.
//

import Foundation

// MARK: - Toki Adapter

/// Adapter to make Toki conform to IGachaItem
class TokiGachaItem: IGachaItem {
    private let toki: Toki
    
    // IGachaItem properties
    var id: UUID { return toki.id }
    var name: String { return toki.name }
    var rarity: ItemRarity { return toki.rarity }
    var elementType: ElementType { return toki.elementType }
    var ownerId: UUID?
    var dateAcquired: Date?
    
    init(toki: Toki, ownerId: UUID? = nil, dateAcquired: Date? = nil) {
        self.toki = toki
        self.ownerId = ownerId
        self.dateAcquired = dateAcquired
    }
    
    /// Get the wrapped Toki object
    func getToki() -> Toki {
        return toki
    }
    
}

// MARK: - Skill Adapter

/// Adapter to make Skill conform to IGachaItem
class SkillGachaItem: IGachaItem {
    private let skill: Skill
    
    // IGachaItem properties
    var id: UUID { return skill.id }
    var name: String { return skill.name }
    var rarity: ItemRarity
    var elementType: ElementType { return skill.elementType }
    var ownerId: UUID?
    var dateAcquired: Date?
    
    init(skill: Skill, rarity: ItemRarity = .common, ownerId: UUID? = nil, dateAcquired: Date? = nil) {
        self.skill = skill
        self.rarity = rarity
        self.ownerId = ownerId
        self.dateAcquired = dateAcquired
    }
    
    /// Get the wrapped Skill object
    func getSkill() -> Skill {
        return skill
    }
}

// MARK: - Equipment Adapter

/// Adapter to make Equipment conform to IGachaItem
class EquipmentGachaItem: IGachaItem {
    private let equipment: Equipment
    
    // IGachaItem properties
    var id: UUID { return equipment.id }
    var name: String { return equipment.name }
    var rarity: ItemRarity
    var elementType: ElementType
    var ownerId: UUID?
    var dateAcquired: Date?
    
    init(equipment: Equipment, elementType: ElementType = .neutral, ownerId: UUID? = nil, dateAcquired: Date? = nil) {
        self.equipment = equipment
        self.rarity = .common
        self.elementType = elementType
        self.ownerId = ownerId
        self.dateAcquired = dateAcquired
        self.rarity = convertEquipmentRarityToItemRarity(equipment.rarity)
    }
    
    /// Get the wrapped Equipment object
    func getEquipment() -> Equipment {
        return equipment
    }
    
    /// Get as consumable equipment if applicable
    func getConsumableEquipment() -> ConsumableEquipment? {
        return equipment as? ConsumableEquipment
    }
    
    /// Get as non-consumable equipment if applicable
    func getNonConsumableEquipment() -> NonConsumableEquipment? {
        return equipment as? NonConsumableEquipment
    }
    
    /// Convert from Equipment's integer rarity to IGachaItem's rarity
    private func convertEquipmentRarityToItemRarity(_ equipmentRarity: Int) -> ItemRarity {
        switch equipmentRarity {
        case 0: return .common
        case 1: return .rare
        case 2: return .epic
        default: return .common
        }
    }
}

// MARK: - Factory Methods

/// Factory to create various GachaItem adapters
class GachaItemFactory {
    
    /// Create a GachaItem adapter for a Toki
    static func createTokiGachaItem(toki: Toki, ownerId: UUID? = nil, dateAcquired: Date? = nil) -> TokiGachaItem {
        return TokiGachaItem(toki: toki, ownerId: ownerId, dateAcquired: dateAcquired)
    }
    
    /// Create a GachaItem adapter for a Skill
    static func createSkillGachaItem(skill: Skill, rarity: ItemRarity = .common, ownerId: UUID? = nil, dateAcquired: Date? = nil) -> SkillGachaItem {
        return SkillGachaItem(skill: skill, rarity: rarity, ownerId: ownerId, dateAcquired: dateAcquired)
    }
    
    /// Create a GachaItem adapter for Equipment
    static func createEquipmentGachaItem(equipment: Equipment, elementType: ElementType = .neutral, ownerId: UUID? = nil, dateAcquired: Date? = nil) -> EquipmentGachaItem {
        return EquipmentGachaItem(equipment: equipment, elementType: elementType, ownerId: ownerId, dateAcquired: dateAcquired)
    }
}

