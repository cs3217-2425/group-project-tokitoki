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
    
    func changeEquipmentTapped(_ sender: UIButton, _ control: TokiDisplayViewController) {
        guard let indexPath = control.equipmentTableView?.indexPathForSelectedRow else {
            let noSelectionAlert = UIAlertController(title: "No Selection",
                                                     message: "Please select an equipment cell to change.",
                                                     preferredStyle: .alert)
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(noSelectionAlert, animated: true)
            return
        }
        
        let component = self.equipmentFacade.equipmentComponent
        
        // Build an action sheet using all equipment loaded from JSON.
        let alert = UIAlertController(title: "Change Equipment", message: "Select a new equipment", preferredStyle: .actionSheet)
        
        for equipment in component.inventory {
            alert.addAction(UIAlertAction(title: equipment.name, style: .default, handler: { _ in
                // Check if this equipment is already part of the Toki's equipment.
                if self.toki.equipments.contains(where: { $0.id == equipment.id }) {
                    let existsAlert = UIAlertController(title: "Already Exists",
                                                        message: "Equipment \(equipment.name) already exists.",
                                                        preferredStyle: .alert)
                    existsAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    control.present(existsAlert, animated: true)
                } else {
                    // Update the Toki model.
                    if indexPath.row < self.toki.equipments.count {
                        self.toki.equipments[indexPath.row] = equipment
                    } else {
                        self.toki.equipments.append(equipment)
                    }
                    // Now update the facade's inventory to reflect this change.
                    let component = self.equipmentFacade.equipmentComponent
                    self.equipmentFacade.equipmentComponent = component
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
