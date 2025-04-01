//
//  Equipment.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation

/// Equipment holds a name, description, element type and a list of equipment buff components.
/// It provides methods to apply or remove its buffs on a character’s StatsComponent.
class Equipment: IGachaItem {
    let id: UUID
    let name: String
    let description: String
    let elementType: ElementType
    let components: [EquipmentComponent]
    let rarity: ItemRarity
    
    // Optional reference to owner
    var ownerId: UUID?
    var dateAcquired: Date?
    
    init(id: UUID = UUID(), name: String, description: String, elementType: ElementType, components: [EquipmentComponent], rarity: ItemRarity = .common, ownerId: UUID? = nil, dateAcquired: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.elementType = elementType
        self.components = components
        self.rarity = rarity
        self.ownerId = ownerId
        self.dateAcquired = dateAcquired
    }
    
    /// Applies all buff components to the provided StatsComponent.
    func applyBuffs(to stats: inout StatsComponent) {
        components.forEach { $0.apply(to: &stats) }
    }
    
    /// Removes all buff components from the provided StatsComponent.
    func removeBuffs(from stats: inout StatsComponent) {
        components.forEach { $0.remove(from: &stats) }
    }
}
