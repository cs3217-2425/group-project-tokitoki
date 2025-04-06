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
    
    func useConsumable(_ consumable: ConsumableEquipment, at indexPath: IndexPath,
                       equipmentTableView: UITableView?, control: TokiDisplayViewController) {
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
        if let tokiIndex = TokiDisplay.shared.toki.equipments.firstIndex(where: { $0.id == consumable.id }) {
            TokiDisplay.shared.toki.equipments.remove(at: tokiIndex)
        }

        // 4. Reload the table to reflect the changes
        equipmentTableView?.reloadData()
        self.updateUI(control)
    }
    
    func changeSkillsTapped(_ sender: UIButton, _ control: TokiDisplayViewController) {
        guard let indexPath = control.skillsTableView?.indexPathForSelectedRow else {
            let noSelectionAlert = UIAlertController(title: "No Selection",
                                                     message: "Please select a skill cell to change.",
                                                     preferredStyle: .alert)
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(noSelectionAlert, animated: true)
            return
        }
        
        // Build an action sheet using all skills loaded from JSON.
        let alert = UIAlertController(title: "Change Skill", message: "Select a new skill", preferredStyle: .actionSheet)
        
        // Iterate over allSkills array loaded from JSON.
        for skill in self.allSkills {
            alert.addAction(UIAlertAction(title: skill.name, style: .default, handler: { _ in
                // Check if this skill is already part of the Toki's skills.
                if self.toki.skills.contains(where: { $0.name == skill.name }) {
                    let existsAlert = UIAlertController(title: "Already Exists",
                                                        message: "Skill \(skill.name) already exists.",
                                                        preferredStyle: .alert)
                    existsAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    control.present(existsAlert, animated: true)
                } else {
                    if indexPath.row < self.toki.skills.count {
                        self.toki.skills[indexPath.row] = skill
                    } else {
                        self.toki.skills.append(skill)
                    }
                    self.updateUI(control)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        control.present(alert, animated: true)
    }
    
    func levelUp(_ sender: UIButton, _ control: TokiDisplayViewController) {
        if toki.baseStats.exp >= 100 {
            let alert = UIAlertController(title: "Level Up", message: "Choose a stat to increase", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Attack", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: 10, attack: 1, defense: 0, speed: 0, heal: 0, exp: 0))
                self.updateUI(control)
            }))
            alert.addAction(UIAlertAction(title: "Defense", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: 10, attack: 0, defense: 1, speed: 0, heal: 0, exp: 0))
                self.updateUI(control)
            }))
            alert.addAction(UIAlertAction(title: "Speed", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: 10, attack: 0, defense: 0, speed: 1, heal: 0, exp: 0))
                self.updateUI(control)
            }))
            alert.addAction(UIAlertAction(title: "Heal", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: 10, attack: 0, defense: 0, speed: 0, heal: 1, exp: 0))
                self.updateUI(control)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            control.present(alert, animated: true, completion: nil)
        }
    }
}
