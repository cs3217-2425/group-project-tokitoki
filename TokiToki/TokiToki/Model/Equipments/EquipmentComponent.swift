//
//  EquipmentComponent.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

class EquipmentComponent {
    var inventory: [Equipment] = []
    var equipped: [EquipmentSlot: NonConsumableEquipment] = [:]

    init(inventory: [Equipment] = [], equipped: [EquipmentSlot: NonConsumableEquipment] = [:]) {
        self.inventory = inventory
        self.equipped = equipped
    }
}
