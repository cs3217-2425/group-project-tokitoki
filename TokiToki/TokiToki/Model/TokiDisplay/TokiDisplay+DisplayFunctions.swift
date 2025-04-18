//
//  TokiDisplay+DisplayFunctions.swift
//  TokiToki
//
//  Created by wesho on 3/4/25.
//

import UIKit

extension TokiDisplay {
    func useConsumable(_ consumable: ConsumableEquipment, at indexPath: IndexPath,
                       equipmentTableView: UITableView?, control: TokiDisplayViewController) {
        // 1. Use it on the real Toki so that Toki’s exp updates
        self.equipmentFacade.useConsumable(
            consumable: consumable,
            on: self.toki
        )

        // 2. Remove from the facade’s inventory so it no longer appears in the table
        let component = self.equipmentFacade.equipmentComponent
        if let idx = component.inventory.firstIndex(where: { $0.id == consumable.id }) {
            component.inventory.remove(at: idx)
            self.equipmentFacade.equipmentComponent = component
        }

        // 3. Also remove from Toki’s equipment array to keep them in sync (if Toki had it).
        if let tokiIndex = self.toki.equipments.firstIndex(where: { $0.id == consumable.id }) {
            self.toki.equipments.remove(at: tokiIndex)
        }

        // 4. Reload the table to reflect the changes
        equipmentTableView?.reloadData()
        self.updateUI(control)
    }

    func changeEquipmentTapped(_ sender: UIButton,
                                _ control: TokiDisplayViewController) {
         // 1) Ensure a slot is selected
         guard let indexPath = control.equipmentTableView?.indexPathForSelectedRow else {
             let alert = UIAlertController(
                 title: "No Selection",
                 message: "Please select an equipment cell to change.",
                 preferredStyle: .alert
             )
             alert.addAction(UIAlertAction(title: "OK", style: .default))
             control.present(alert, animated: true)
             return
         }

         // 2) Determine which slot the user wants to change
         let slotOrder: [EquipmentSlot] = [.weapon, .armor, .accessory, .custom]
         let targetSlot = indexPath.row < slotOrder.count
                        ? slotOrder[indexPath.row]
                        : .custom

         // 3) Grab the up‑to‑date inventory
         let component = self.equipmentFacade.equipmentComponent

         // 4) Build a set of every equipped‐item ID across ALL Tokis
         let allEquippedIDs = Set(self.allTokis.flatMap { $0.equipments.map(\.id) })

         // 5) Filter inventory to only those _not_ in any Toki’s equipments
         let available = component.inventory.filter { inv in
             !allEquippedIDs.contains(inv.id)
         }

         // 6) Build and present the action sheet
         let alert = UIAlertController(
             title: "Change Equipment",
             message: "Select a new equipment",
             preferredStyle: .actionSheet
         )

         for equipment in available {
             alert.addAction(UIAlertAction(title: equipment.name, style: .default) { _ in
                 // Equip it (handles inventory removal + old‑slot return)
                 self.equipmentFacade.equipItem(equipment, to: targetSlot)

                 // Sync the Toki model in slot order
                 let updatedEquipped = self.equipmentFacade.equipmentComponent.equipped
                 self.toki.equipments = slotOrder.compactMap { updatedEquipped[$0] }

                 // Persist & refresh
                 self.saveTokiState()
                 self.updateUI(control)
             })
         }

         alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

         if let pop = alert.popoverPresentationController {
             pop.sourceView = sender
             pop.sourceRect = sender.bounds
         }
         control.present(alert, animated: true)
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
                    // Update the Toki model.
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
        if toki.level == maxLevel {
            return
        }
        let statIncrease = 5
        let hpIncrease = 30
        let tokiLevel = toki.level
        if toki.baseStats.exp >= levelInfo[tokiLevel] {
            let alert = UIAlertController(title: "Level Up", message: "Choose a stat to increase", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Attack", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: hpIncrease, attack: statIncrease, defense: 0, speed: 0,
                                                      heal: 0, exp: 0))
                self.updateUI(control)
                PlayerManager.shared.savePlayer()
            }))
            alert.addAction(UIAlertAction(title: "Defense", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: hpIncrease, attack: 0, defense: statIncrease, speed: 0,
                                                      heal: 0, exp: 0))
                self.updateUI(control)
            }))
            alert.addAction(UIAlertAction(title: "Speed", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: hpIncrease, attack: 0, defense: 0, speed: statIncrease,
                                                      heal: 0, exp: 0))
                self.updateUI(control)
            }))
            alert.addAction(UIAlertAction(title: "Heal", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: hpIncrease, attack: 0, defense: 0, speed: 0,
                                                      heal: statIncrease, exp: 0))
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
    
    func showCraftingPopup(for item: Equipment, at originalIndex: Int, _ vcont: TokiDisplayViewController) {
        let craftVC = CraftingPopupViewController()

        // Pass along the original item and its index in the inventory.
        craftVC.originalItem = item
        craftVC.originalItemIndex = originalIndex
        
        // Pass the TokiDisplay instance (or any other dependency) from the parent view controller.
        craftVC.tokiDisplay = vcont.tokiDisplay

        // Present as a popover or modal.
        craftVC.modalPresentationStyle = .popover

        if let popover = craftVC.popoverPresentationController {
            popover.sourceView = vcont.view
            popover.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }

        // Optionally, set a callback so we can reload Toki UI after crafting.
        craftVC.onCraftComplete = { [weak vcont] in
            guard let strongSelf = vcont else {
                // The view controller no longer exists; just return.
                return
            }
            strongSelf.equipmentTableView?.reloadData()
            strongSelf.tokiDisplay?.updateUI(strongSelf)
        }

        vcont.present(craftVC, animated: true, completion: nil)
    }
}
