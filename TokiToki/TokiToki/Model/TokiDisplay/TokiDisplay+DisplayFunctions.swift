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

        let potionStrategy = PotionEffectStrategy(buffValue: 10, duration: 5)
        let healthPotion = repository.createConsumableEquipment(name: "Health Potion",
                                                                description: "Restores health temporarily.",
                                                                rarity: 1,
                                                                effectStrategy: potionStrategy, usageContext: .battleOnly)

        let upgradeCandyStrategy = UpgradeCandyEffectStrategy(bonusExp: 50)
        let upgradeCandy = repository.createConsumableEquipment(name: "Upgrade Candy",
                                                                description: "Grants bonus EXP permanently.",
                                                                rarity: 1,
                                                                effectStrategy: upgradeCandyStrategy, usageContext: .outOfBattleOnly)

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
    
    func useConsumable(_ consumable: ConsumableEquipment, at indexPath: IndexPath, equipmentTableView: UITableView?, control: TokiDisplayViewController) {
        // 1. Use it on the real Toki so that Toki’s exp updates
        TokiDisplay.shared.equipmentFacade.useConsumable(
            consumable: consumable,
            on: TokiDisplay.shared.toki
        )

        // 2. Remove from the facade’s inventory so it no longer appears in the table
        let component = TokiDisplay.shared.equipmentFacade.equipmentComponent
        if let idx = component.inventory.firstIndex(where: { $0.id == consumable.id }) {
            component.inventory.remove(at: idx)
            TokiDisplay.shared.equipmentFacade.equipmentComponent = component
        }

        // 3. Also remove from Toki’s equipment array to keep them in sync (if Toki had it).
        if let tokiIndex = TokiDisplay.shared.toki.equipment.firstIndex(where: { $0.id == consumable.id }) {
            TokiDisplay.shared.toki.equipment.remove(at: tokiIndex)
        }

        // 4. Reload the table to reflect the changes
        equipmentTableView?.reloadData()
        self.updateUI(control)
    }
}
