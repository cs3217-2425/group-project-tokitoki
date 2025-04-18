//
//  EquipmentCommand.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

protocol EquipmentCommand {
    func execute()
    func undo() // Supports undoing actions
}

class UseConsumableCommand: EquipmentCommand {
    private let consumable: ConsumableEquipment
    private let toki: Toki
    private let component: EquipmentComponent
    private let equipmentSystem: EquipmentSystem
    private let logger: EquipmentLogger

    init(consumable: ConsumableEquipment,
         toki: Toki,
         component: EquipmentComponent,
         system: EquipmentSystem,
         logger: EquipmentLogger) {
        self.consumable = consumable
        self.toki = toki
        self.component = component
        self.equipmentSystem = system
        self.logger = logger
    }

    func execute() {
        equipmentSystem.useConsumable(
            consumable,
            on: toki,
            orOn: nil,
            in: component,
            EffectCalculationContext()
        )
        logger.logEvent(.consumed(item: consumable))
    }

    func undo() {
        logger.log("Undo not supported for consumable usage.")
    }
}

class EquipCommand: EquipmentCommand {
    private let item: NonConsumableEquipment
    private let component: EquipmentComponent
    private let equipmentSystem: EquipmentSystem
    private let logger: EquipmentLogger
    private var previousItem: Equipment?

    init(item: NonConsumableEquipment,
         component: EquipmentComponent,
         system: EquipmentSystem,
         logger: EquipmentLogger) {
        self.item = item
        self.component = component
        self.equipmentSystem = system
        self.logger = logger
    }

    func execute() {
        // 1) remember whatever was in that slot
        previousItem = component.equipped[item.slot]
        // 2) equip the new item into its slot
        equipmentSystem.equipItem(
            item,
            slot: item.slot,
            in: component
        )
        logger.logEvent(.equipped(item: item))
    }

    func undo() {
        if let prev = previousItem {
            // re‑equip the previous item back into the same slot
            equipmentSystem.equipItem(
                prev,
                slot: item.slot,
                in: component
            )
            logger.log("Reverted equip to \(prev.name)")
        } else {
            // no previous item → just unequip current
            equipmentSystem.unequipItem(
                from: item.slot,
                in: component
            )
            logger.log("Undid equipping of \(item.name)")
        }
    }
}

class CraftCommand: EquipmentCommand {
    private let items: [Equipment]
    private let component: EquipmentComponent
    private let craftingManager: CraftingManager
    private let logger: EquipmentLogger
    private(set) var craftedItem: Equipment?

    init(items: [Equipment],
         component: EquipmentComponent,
         craftingManager: CraftingManager,
         logger: EquipmentLogger) {
        self.items = items
        self.component = component
        self.craftingManager = craftingManager
        self.logger = logger
    }

    func execute() {
        if let newItem = craftingManager.craft(with: items) {
            // Valid recipe – remove the ingredients…
            for ingredient in items {
                if let idx = component.inventory.firstIndex(where: { $0.id == ingredient.id }) {
                    component.inventory.remove(at: idx)
                }
            }
            // …and append the crafted result
            craftedItem = newItem
            component.inventory.append(newItem)
            logger.logEvent(.crafted(item: newItem))
        } else {
            // Invalid recipe → build a clean reason string
            let names = items.map { $0.name }.joined(separator: ", ")
            logger.logEvent(.craftingFailed(
                reason: "Invalid recipe for items: \(names)")
            )
        }
    }

    func undo() {
        if let crafted = craftedItem,
           let idx = component.inventory.firstIndex(where: { $0.id == crafted.id }) {
            // remove the crafted and return the ingredients
            component.inventory.remove(at: idx)
            component.inventory.append(contentsOf: items)
            logger.log("Undid crafting of \(crafted.name)")
        }
    }
}
