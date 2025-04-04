//
//  EquipmentSystem.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

extension Notification.Name {
    static let EquipmentEquipped = Notification.Name("EquipmentEquipped")
    static let EquipmentConsumed = Notification.Name("EquipmentConsumed")
}

class EquipmentSystem {
    var priority: Int = 0

    func update(deltaTime: TimeInterval) {
        // Future: Process temporary buff expirations, cooldowns, etc.
    }

    func useConsumable(_ equipment: ConsumableEquipment, on toki: Toki, in component: EquipmentComponent) {
        equipment.effectStrategy.applyEffect(to: toki) {
            NotificationCenter.default.post(name: .EquipmentConsumed, object: equipment)
        }
        if let index = component.inventory.firstIndex(where: { $0.id == equipment.id }) {
            component.inventory.remove(at: index)
        }
    }

    func equipItem(_ item: NonConsumableEquipment, in component: EquipmentComponent) {
        // Replace any existing item in the same slot.
        if let existing = component.equipped[item.slot] {
            component.inventory.append(existing)
        }
        component.equipped[item.slot] = item
        if let index = component.inventory.firstIndex(where: { $0.id == item.id }) {
            component.inventory.remove(at: index)
        }
        NotificationCenter.default.post(name: .EquipmentEquipped, object: item)
    }

    func unequipItem(from slot: EquipmentSlot, in component: EquipmentComponent) {
        if let item = component.equipped.removeValue(forKey: slot) {
            component.inventory.append(item)
        }
    }
}
