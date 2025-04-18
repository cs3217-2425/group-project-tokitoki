//
//  EquipmentComponent.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

// Used by both the player and each individual Toki
class EquipmentComponent: Component {
    var inventory: [Equipment] = []
    var equipped: [EquipmentSlot: Equipment] = [:]
    var entity: Entity
    var savedInventory: [Equipment] = []

    init(inventory: [Equipment] = [],
         equipped: [EquipmentSlot: Equipment] = [:], entity: Entity = BaseEntity()) {
        self.inventory = inventory
        self.equipped = equipped
        self.entity = entity
        self.savedInventory = inventory
    }
}
