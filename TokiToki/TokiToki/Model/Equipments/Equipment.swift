//
//  Equipment.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation

/// Equipment holds a name, description, element type and a list of equipment buff components.
/// It provides methods to apply or remove its buffs on a character’s StatsComponent.
class Equipment {
    let name: String
    let description: String
    let elementType: ElementType
    let components: [EquipmentComponent]

    init(name: String, description: String, elementType: ElementType, components: [EquipmentComponent]) {
        self.name = name
        self.description = description
        self.elementType = elementType
        self.components = components
    }

    /// Applies all buff components to the provided StatsComponent.
    func applyBuffs(to stats: inout StatsComponent) {
        components.forEach { $0.apply(to: &stats) }
    } // Should use system to update stats components

    /// Removes all buff components from the provided StatsComponent.
    func removeBuffs(from stats: inout StatsComponent) {
        components.forEach { $0.remove(from: &stats) }
    }
}
