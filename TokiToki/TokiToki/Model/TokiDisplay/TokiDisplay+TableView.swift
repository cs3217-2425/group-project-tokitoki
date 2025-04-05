//
//  TokiDisplay+TableView.swift
//  TokiToki
//
//  Created by Wh Kang on 5/4/25.
//

import UIKit

extension TokiDisplay {
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int, _ control: TokiDisplayViewController) -> Int {
        let baseSlots = 1
        let extraSlots = toki.level / 5
        let totalSlots = baseSlots + extraSlots
        if tableView == control.equipmentTableView {
            return max(totalSlots, toki.equipment.count)
        } else {
            return max(totalSlots, toki.skills.count)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, _ control: TokiDisplayViewController) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokiTableCell", for: indexPath) as? TokiTableCell else {
            return UITableViewCell()
        }
        
        if tableView == control.equipmentTableView {
            if indexPath.row < toki.equipment.count {
                let equipmentItem = toki.equipment[indexPath.row]
                cell.nameLabel.text = equipmentItem.name
                cell.itemImageView.image = UIImage(named: equipmentItem.name)
                let longPress = UILongPressGestureRecognizer(target: control, action: #selector(control.handleEquipmentLongPress(_:)))
                cell.addGestureRecognizer(longPress)
            } else {
                cell.nameLabel.text = "Empty Slot"
                cell.itemImageView.image = UIImage(named: "empty")
                let longPress = UILongPressGestureRecognizer(target: control, action: #selector(control.handleEquipmentLongPress(_:)))
                cell.addGestureRecognizer(longPress)
            }
        } else {
            if indexPath.row < toki.skills.count {
                let skillItem = toki.skills[indexPath.row]
                cell.nameLabel.text = skillItem.name
                cell.itemImageView.image = UIImage(named: skillItem.name)
                let longPress = UILongPressGestureRecognizer(target: control, action: #selector(control.handleSkillLongPress(_:)))
                cell.addGestureRecognizer(longPress)
            } else {
                cell.nameLabel.text = "Empty Slot"
                cell.itemImageView.image = UIImage(named: "empty")
                let longPress = UILongPressGestureRecognizer(target: control, action: #selector(control.handleSkillLongPress(_:)))
                cell.addGestureRecognizer(longPress)
            }
        }
        
        return cell
    }
    
    // Provide the trailing swipe configuration.
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath,
                   _ control: TokiDisplayViewController) -> UISwipeActionsConfiguration? {

        let inventory = self.equipmentFacade.equipmentComponent.inventory

        // Make sure the row is valid for the current inventory
        guard indexPath.row < inventory.count else { return nil }

        let item = inventory[indexPath.row]
        var actions = [UIContextualAction]()

        // If item is consumable, check usage context
        if let consumable = item as? ConsumableEquipment {
            switch consumable.usageContext {
            case .battleOnly:
                // Do NOT show the "Use" action if it's only for battle
                break

            case .outOfBattleOnly, .anywhere:
                let useAction = UIContextualAction(style: .normal, title: "Use") { _, _, completion in
                    self.useConsumable(consumable, at: indexPath, equipmentTableView: tableView, control: control)
                    completion(true)
                }
                useAction.backgroundColor = .systemGreen
                actions.append(useAction)
            }
        }

        let craftAction = UIContextualAction(style: .normal, title: "Craft") { _, _, completion in
            control.showCraftingPopup(for: item, at: indexPath.row)
            completion(true)
            tableView.reloadData()
        }
        craftAction.backgroundColor = .systemBlue
        actions.append(craftAction)

        return UISwipeActionsConfiguration(actions: actions)
    }
}

