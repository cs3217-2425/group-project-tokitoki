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
    func update(_ entities: [GameStateEntity]) {
        // Future: Process temporary buff expirations, cooldowns, etc.
    }

    func useConsumable(_ equipment: ConsumableEquipment, on toki: Toki?, orOn entity: GameStateEntity?,
                       in component: EquipmentComponent,
                       _ context: EffectCalculationContext) -> [EffectResult]? {
        let results = equipment.effectStrategy.applyEffect(name: equipment.name, to: toki, orTo: entity,
                                                           context) {
            NotificationCenter.default.post(name: .EquipmentConsumed, object: equipment)
        }
        removeEquipment(&component.inventory, equipment)
        if let index = entity?.toki.equipments.firstIndex(where: { $0.id == equipment.id }) {
            entity?.toki.equipments.remove(at: index)
        }

        return results
    }

    func applyPassiveConsumable(_ entity: GameStateEntity,
                                _ context: EffectCalculationContext) -> [EffectResult] {
        guard let equipmentComponent = entity.getComponent(ofType: EquipmentComponent.self) else {
            return []
        }
        var overallResults: [EffectResult] = []
        for consumable in equipmentComponent.inventory {
            guard let passiveConsumable = consumable as? ConsumableEquipment,
                    passiveConsumable.usageContext == .battleOnlyPassive else {
                return []
            }
            let results = passiveConsumable.effectStrategy.applyEffect(name: passiveConsumable.name, to: entity.toki,
                                                                       orTo: entity,
                                                                       context) {
                NotificationCenter.default.post(name: .EquipmentConsumed, object: passiveConsumable)
            }

            // passive did not activate
            guard let results = results else {
                return []
            }
            removeEquipment(&equipmentComponent.inventory, passiveConsumable)
            removeEquipment(&entity.toki.equipments, passiveConsumable)
            overallResults += results
        }
        return overallResults
    }

    private func removeEquipment(_ equipments: inout [Equipment], _ equipment: Equipment) {
        guard let index = equipments.firstIndex(where: { $0.id == equipment.id }) else {
            return
        }
        equipments.remove(at: index)
    }

    func equipItem(_ item: Equipment, slot: EquipmentSlot, in component: EquipmentComponent) {
        // Replace any existing item in the same slot.
        if let existing = component.equipped[slot] {
            component.inventory.append(existing)
        }
        component.equipped[slot] = item
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

    func reset(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let equipmentComponent = entity.getComponent(ofType: EquipmentComponent.self) else {
                return
            }
            equipmentComponent.inventory = equipmentComponent.savedInventory
            entity.toki.equipments = entity.toki.savedEquipments
        }
    }

    func countConsumables(_ entity: GameStateEntity) -> [ConsumableGroupings] {
        guard let equipmentComponent = entity.getComponent(ofType: EquipmentComponent.self) else {
            return []
        }

        let countsDict = equipmentComponent.inventory
            .filter { item in
                guard item.equipmentType == .consumable,
                      let consumable = item as? ConsumableEquipment else { return false }
                return consumable.usageContext == .battleOnly || consumable.usageContext == .anywhere
            }
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
