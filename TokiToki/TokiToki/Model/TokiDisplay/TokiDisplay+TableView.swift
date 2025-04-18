//
//  TokiDisplay+TableView.swift
//  TokiToki
//
//  Created by Wh Kang on 5/4/25.
//

import UIKit

extension TokiDisplay {
    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int,
                   _ control: TokiDisplayViewController) -> Int {
        let baseSlots = 1
        let extraSlots = toki.level / 5
        let totalSlots = baseSlots + extraSlots

        if tableView == control.equipmentTableView {
            return max(totalSlots, toki.equipments.count)
        } else {
            return max(totalSlots, toki.skills.count)
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath,
                   _ control: TokiDisplayViewController) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokiTableCell",
                                                       for: indexPath) as? TokiTableCell else {
            return UITableViewCell()
        }

        if tableView == control.equipmentTableView {
            if indexPath.row < toki.equipments.count {
                let equipmentItem = toki.equipments[indexPath.row]
                cell.nameLabel.text = equipmentItem.name
                cell.itemImageView.image = UIImage(named: equipmentItem.name)
                let longPress = UILongPressGestureRecognizer(
                    target: control,
                    action: #selector(control.handleEquipmentLongPress(_:))
                )
                cell.addGestureRecognizer(longPress)
            } else {
                cell.nameLabel.text = "Empty Slot"
                cell.itemImageView.image = UIImage(named: "empty")
                let longPress = UILongPressGestureRecognizer(
                    target: control,
                    action: #selector(control.handleEquipmentLongPress(_:))
                )
                cell.addGestureRecognizer(longPress)
            }
        } else {
            if indexPath.row < toki.skills.count {
                let skillItem = toki.skills[indexPath.row]
                cell.nameLabel.text = skillItem.name
                cell.itemImageView.image = UIImage(named: skillItem.name)
                let longPress = UILongPressGestureRecognizer(
                    target: control,
                    action: #selector(control.handleSkillLongPress(_:))
                )
                cell.addGestureRecognizer(longPress)
            } else {
                cell.nameLabel.text = "Empty Slot"
                cell.itemImageView.image = UIImage(named: "empty")
                let longPress = UILongPressGestureRecognizer(
                    target: control,
                    action: #selector(control.handleSkillLongPress(_:))
                )
                cell.addGestureRecognizer(longPress)
            }
        }

        return cell
    }

    // MARK: - TableView Swipe Actions

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath,
                   _ control: TokiDisplayViewController) -> UISwipeActionsConfiguration? {
        // Only show swipe actions on the equipment table
        guard tableView == control.equipmentTableView else {
            return nil
        }

        // If there's no actual equipment in this row, skip
        let equippedItems = toki.equipments
        guard indexPath.row < equippedItems.count else {
            return nil
        }

        let item = equippedItems[indexPath.row]
        var actions: [UIContextualAction] = []

        // 1) Unequip action
        let slotOrder: [EquipmentSlot] = [.weapon, .armor, .accessory, .custom]
        let targetSlot = indexPath.row < slotOrder.count
                       ? slotOrder[indexPath.row]
                       : .custom

        let unequipAction = UIContextualAction(style: .destructive,
                                               title: "Unequip") { _, _, completion in
            // Remove from slot → back to inventory
            self.equipmentFacade.unequipItem(slot: targetSlot)
            // Sync Toki.equipments in slot order
            self.toki.equipments = slotOrder.compactMap {
                self.equipmentFacade.equipmentComponent.equipped[$0]
            }
            // Persist and refresh UI
            self.saveTokiState()
            self.updateUI(control)
            completion(true)
        }
        actions.append(unequipAction)

        // 2) Use (if consumable and allowed out of battle)
        if let consumable = item as? ConsumableEquipment {
            switch consumable.usageContext {
            case .battleOnly, .battleOnlyPassive:
                break
            case .outOfBattleOnly, .anywhere:
                let useAction = UIContextualAction(style: .normal,
                                                   title: "Use") { _, _, completion in
                    self.useConsumable(consumable,
                                       at: indexPath,
                                       equipmentTableView: tableView,
                                       control: control)
                    completion(true)
                }
                useAction.backgroundColor = .systemGreen
                actions.append(useAction)
            }
        }

        // 3) Craft
        let craftAction = UIContextualAction(style: .normal,
                                             title: "Craft") { _, _, completion in
            control.showCraftingPopup(for: item,
                                      at: indexPath.row)
            completion(true)
            tableView.reloadData()
        }
        craftAction.backgroundColor = .systemBlue
        actions.append(craftAction)

        return UISwipeActionsConfiguration(actions: actions)
    }
}

