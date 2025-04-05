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
    
    func equipItem(item: NonConsumableEquipment) {
        let command = EquipCommand(item: item,
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
