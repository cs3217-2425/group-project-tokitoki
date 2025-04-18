//
//  TokiDisplay+Handler.swift
//  TokiToki
//
//  Created by wesho on 3/4/25.
//

import UIKit

extension TokiDisplay {
    func handleEquipmentLongPress(_ gesture: UILongPressGestureRecognizer, _ control: TokiDisplayViewController) {
        if gesture.state == .began {
            guard let cell = gesture.view as? UITableViewCell,
                  let indexPath = control.equipmentTableView?.indexPath(for: cell) else { return }

            let equipment = toki.equipments[indexPath.row]
            var message = equipment.description
            
            // Look for our new EquipmentBuffComponent
            if let buffComp = (equipment as? NonConsumableEquipment)?
                    .components
                    .compactMap({ $0 as? EquipmentBuffComponent })
                    .first {
                let value = buffComp.buff.value
                let lines = EquipmentBuff.Stat.allCases.map { stat in
                    let val = buffComp.buff.affectedStats.contains(stat) ? value : 0
                    return "\(stat.rawValue.capitalized) Buff: \(val)"
                }
                message = lines.joined(separator: "\n")
            }

            let alert = UIAlertController(title: equipment.name,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(alert, animated: true)
        }
    }

    func handleSkillLongPress(_ gesture: UILongPressGestureRecognizer, _ control: TokiDisplayViewController) {
        if gesture.state == .began {
            guard let cell = gesture.view as? UITableViewCell,
                  let indexPath = control.skillsTableView?.indexPath(for: cell) else { return }
            let skill = toki.skills[indexPath.row]
            let message = "Description: \(skill.description)\nCooldown: \(skill.cooldown)"
            let alert = UIAlertController(title: skill.name,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(alert, animated: true)
        }
    }
}

