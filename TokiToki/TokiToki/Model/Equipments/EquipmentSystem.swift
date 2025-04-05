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

class EquipmentSystem: System {
    static let shared = EquipmentSystem()
    var priority: Int = 0
    var equipmentComponent = PlayerManager.shared.getOrCreatePlayer().ownedEquipments
    var savedEquipments: [Equipment] = []
    
    private init() {}
    
    func update(_ entities: [GameStateEntity]) {
        // Future: Process temporary buff expirations, cooldowns, etc.
    }
    
    func saveEquipments() {
        self.savedEquipments = self.equipmentComponent.inventory
    }
    
    func reset(_ entities: [GameStateEntity]) {
        equipmentComponent.inventory = savedEquipments
    }

    func useConsumable(_ equipment: ConsumableEquipment, on toki: Toki?,
                       _ entity: GameStateEntity?)
    -> [EffectResult]? {
        let results = equipment.applyEffect(to: toki, entity) {
            NotificationCenter.default.post(name: .EquipmentConsumed, object: equipment)
        }
        if let index = equipmentComponent.inventory.firstIndex(where: { $0.id == equipment.id }) {
            equipmentComponent.inventory.remove(at: index)
        }
        return results
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
    
    func getConsumable(_ name: String) -> Equipment? {
        equipmentComponent.inventory.first { $0.equipmentType == .consumable && $0.name == name }
    }
    
    func countConsumables() -> [ConsumableGroupings] {
        let countsDict = equipmentComponent.inventory
           .filter { $0.equipmentType == .consumable }
           .reduce(into: [String: Int]()) { counts, item in
               counts[item.name, default: 0] += 1
           }

       return countsDict.map { ConsumableGroupings(name: $0.key, quantity: $0.value) }
    }
}

struct ConsumableGroupings {
    let name: String
    let quantity: Int
}
