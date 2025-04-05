//
//  TokiDisplay+DisplayFunctions.swift
//  TokiToki
//
//  Created by wesho on 3/4/25.
//

import UIKit

extension TokiDisplay {
    /// Loads sample equipment into the system.
    func loadSampleEquipment() {
        let repository = EquipmentRepository.shared

        let healCalculator = HealCalculator(healPower: 100)
        let healthPotion = Potion(name: "Health Potion",
                                  description: "Restores health temporarily.",
                                  rarity: 1,
                                  effectCalculators: [healCalculator])

        
        let upgradeCandy = Candy(name: "Upgrade Candy",
                                 description: "Grants bonus EXP permanently.",
                                 rarity: 1,
                                 bonusExp: 50)

        let swordBuff = EquipmentBuff(value: 15, description: "Increases attack power", affectedStat: "attack")
        let sword = repository.createNonConsumableEquipment(name: "Sword",
                                                            description: "A sharp blade.",
                                                            rarity: 2,
                                                            buff: swordBuff,
                                                            slot: .weapon)

        let shieldBuff = EquipmentBuff(value: 5, description: "Increases defense", affectedStat: "defense")
        let shield = repository.createNonConsumableEquipment(name: "Shield",
                                                             description: "A sturdy shield.",
                                                             rarity: 2,
                                                             buff: shieldBuff,
                                                             slot: .armor)

        let component = equipmentFacade.equipmentComponent

        let equipmentItems: [Equipment] = [healthPotion, upgradeCandy, sword, shield, healthPotion]
        component.inventory.append(contentsOf: equipmentItems)
        equipmentFacade.equipmentComponent = component
    }

    /// Crafts equipment using the first two items from the inventory.
    func craftEquipment() {
        let component = equipmentFacade.equipmentComponent
        guard component.inventory.count >= 2 else { return }
        let itemsToCraft = Array(component.inventory.prefix(2))
        equipmentFacade.craftItems(items: itemsToCraft)
    }

    /// Equips the first available weapon in the inventory.
    func equipWeapon() {
        let component = equipmentFacade.equipmentComponent
        if let weapon = component.inventory.first(where: {
            $0.equipmentType == .nonConsumable && ($0 as? NonConsumableEquipment)?.slot == .weapon
        }) as? NonConsumableEquipment {
            equipmentFacade.equipItem(item: weapon)
        }
    }
    
    /// Uses the first consumable item found in the inventory.
    func useConsumable() {
        let component = equipmentFacade.equipmentComponent
        if let consumable = component.inventory.first(
            where: { $0.equipmentType == .consumable }
        ) as? ConsumableEquipment {
            let toki = Toki(name: "Demo Toki", rarity: .common, baseStats:
                                TokiBaseStats(hp: 100,
                                              attack: 50,
                                              defense: 50,
                                              speed: 50,
                                              heal: 100,
                                              exp: 42
                                             ), skills: [], equipments: [], elementType: [.fire], level: 1)
            equipmentFacade.useConsumable(consumable: consumable, on: toki, nil)
        }
    }
}
