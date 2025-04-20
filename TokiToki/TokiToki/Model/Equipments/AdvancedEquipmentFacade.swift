//
//  AdvancedEquipmentFacade.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

class AdvancedEquipmentFacade {
    private let serviceLocator = ServiceLocator.shared
    private let commandInvoker = CommandInvoker()

    var equipmentComponent: EquipmentComponent {
        get { serviceLocator.dataStore.load() }
        set { serviceLocator.dataStore.equipmentComponent = newValue }
    }

    func useConsumable(consumable: ConsumableEquipment, on toki: Toki) {
        let command = UseConsumableCommand(consumable: consumable,
                                           toki: toki,
                                           component: equipmentComponent,
                                           system: serviceLocator.equipmentSystem,
                                           logger: serviceLocator.equipmentLogger)
        commandInvoker.execute(command: command)
        serviceLocator.dataStore.save()
    }

    func craftItems(items: [Equipment]) -> Equipment? {
        let command = CraftCommand(items: items,
                                   component: equipmentComponent,
                                   craftingManager: serviceLocator.craftingManager,
                                   logger: serviceLocator.equipmentLogger)
        commandInvoker.execute(command: command)
        serviceLocator.dataStore.save()

        // Return the item that was crafted, or nil if crafting failed
        return command.craftedItem
    }

    func undoLastAction() {
        commandInvoker.undoLast()
        serviceLocator.dataStore.save()
    }
}

// AdvancedEquipmentFacade.swift
extension AdvancedEquipmentFacade {

    /// Equip any Equipment into a specific slot
    func equipItem(_ item: Equipment, to slot: EquipmentSlot) {
        // Directly call the system (no command pattern here for simplicity)
        serviceLocator.equipmentSystem.equipItem(item, slot: slot, in: equipmentComponent)
        // persist updated component
        serviceLocator.dataStore.equipmentComponent = equipmentComponent
    }

    /// Unequip whatever’s in `slot` and return it to inventory.
    func unequipItem(slot: EquipmentSlot) {
        let component = equipmentComponent
        serviceLocator.equipmentSystem.unequipItem(from: slot, in: component)
        // write back into the store
        serviceLocator.dataStore.equipmentComponent = component
    }
}
