//
//  EquipmentComponent.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

class EquipmentComponent: Component {
    var inventory: [Equipment] = []
    var equipped: [EquipmentSlot: NonConsumableEquipment] = [:]
    var entity: Entity
    var savedInventory: [Equipment] = []

    init(inventory: [Equipment] = [],
         equipped: [EquipmentSlot: NonConsumableEquipment] = [:], entity: Entity = BaseEntity()) {
        self.inventory = inventory
        self.equipped = equipped
        self.entity = entity
        self.savedInventory = inventory
    }
}
