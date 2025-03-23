//
//  TokiDisplay.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation
import UIKit

class TokiDisplay {
    static let shared = TokiDisplay()
    var toki: Toki
    
    required init() {
        self.toki = Toki(name: "Default Toki",
                         rarity: .common,
                         baseStats: TokiBaseStats(hp: 100, attack: 50, defense: 50, speed: 50, heal: 100, exp: 42),
                         skills: [],
                         equipments: [],
                         elementType: .fire,
                         level: 1)
    }
    
    private func createTestSkill(name: String = "Thunder Strike") -> Skill {
        let elementsSystem = ElementsSystem()
        
        let effectCalculatorFactory = EffectCalculatorFactory()
        
        let skillsFactory = SkillFactory()
        
        let skill = skillsFactory.createAttackSkill(
            name: name,
            description: "Strikes with thunder power",
            elementType: .light,
            basePower: 50,
            cooldown: 3,
            targetType: .singleEnemy,
            statusEffect: .paralysis,
            statusEffectChance: 0.3,
            statusEffectDuration: 2
        )
        
        return skill
    }
    
    private func createTestEquipment(name: String = "Magic Staff") -> Equipment {
        let equipmentFactory = EquipmentFactory()
        
        let equipment = equipmentFactory.createEquipment(
            name: name,
            description: "A magical staff",
            elementType: .fire,
            buff: Buff(attack: 10, defense: 10, speed: 10)
        )
        
        return equipment
    }
    
    func loadTest() {
        let skill = createTestSkill()
        
        let equipment = createTestEquipment()
        
        self.toki = Toki(name: "Tokimon Omicron 1",
                        rarity: .common,
                        baseStats:
                            TokiBaseStats(
                                hp: 100,
                                attack: 50,
                                defense: 50,
                                speed: 50,
                                heal: 100,
                                exp: 492),
                        skills: [skill],
                        equipments: [equipment],
                        elementType: .fire,
                        level: 1)
    }
    
    
    private func totalEquipmentBuff(for stat: String) -> Float {
        var total: Float = 0
        for equip in toki.equipment {
            if let buffComponent = equip.components.first as? CombinedBuffComponent {
                switch stat {
                case "attack":
                    total += Float(buffComponent.buff.attack)
                case "defense":
                    total += Float(buffComponent.buff.defense)
                case "speed":
                    total += Float(buffComponent.buff.speed)
                default:
                    break
                }
            }
        }
        return total
    }

    private func updateProgressBar(_ progressView: UIProgressView, baseValue: Float,
                                   buffValue: Float, maxValue: Float, baseColor: UIColor, buffColor: UIColor) {
        // Remove any existing subviews from the progress view's track area.
        progressView.subviews.forEach { $0.removeFromSuperview() }
        
        // Calculate ratios.
        let totalValue = baseValue + buffValue
        // Avoid division by zero.
        let baseRatio = totalValue > 0 ? baseValue / maxValue : 0
        let buffRatio = totalValue > 0 ? buffValue / maxValue : 0
        
        // The width of the progress view.
        let totalWidth = progressView.bounds.width
        let height = progressView.bounds.height
        
        // Create the base stat view.
        let baseWidth = totalWidth * CGFloat(baseRatio)
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: baseWidth, height: height))
        baseView.backgroundColor = baseColor
        progressView.addSubview(baseView)
        
        // Create the equipment buff view, positioned immediately after the base portion.
        let buffWidth = totalWidth * CGFloat(buffRatio)
        let buffView = UIView(frame: CGRect(x: baseWidth, y: 0, width: buffWidth, height: height))
        buffView.backgroundColor = buffColor
        progressView.addSubview(buffView)
    }

    func updateUI(_ control: TokiDisplayViewController) {
        control.tokiImageView?.image = UIImage(named: toki.name)
        control.nameLabel?.text = toki.name
        control.levelLabel?.text = "Level: \(toki.level)"
        
        // For stats without equipment buffs, use the regular progress view setting.
        control.hpLabel?.text = "HP: \(toki.baseStats.hp)"
        control.expLabel?.text = "Experience: \(toki.baseStats.exp)"
        control.attackLabel?.text = "Attack: \(toki.baseStats.attack + Int(totalEquipmentBuff(for: "attack")))"
        control.defenseLabel?.text = "Defense: \(toki.baseStats.defense + Int(totalEquipmentBuff(for: "defense")))"
        control.healLabel?.text = "Heal: \(toki.baseStats.heal)"
        control.speedLabel?.text = "Speed: \(toki.baseStats.speed + Int(totalEquipmentBuff(for: "speed")))"
        control.rarityLabel?.text = "Rarity: \(toki.rarity)"
        control.elementLabel?.text = "Element: \(toki.elementType)"
        
        // Example max values; adjust these as needed.
        let hpMax: Float = 420.0
        let expMax: Float = 100.0
        let statMax: Float = 100.0  // For attack, defense, speed
        
        // Update hp and exp progress normally (no equipment buffs assumed)
        control.hpProgressView?.progress = Float(toki.baseStats.hp) / hpMax
        control.expProgressView?.progress = Float(toki.baseStats.exp) / expMax
        
        // For attack, defense, and speed, use the custom two-color progress bars.
        if let attackPV = control.attackProgressView {
            let baseAttack = Float(toki.baseStats.attack)
            let buffAttack = totalEquipmentBuff(for: "attack")
            updateProgressBar(attackPV, baseValue: baseAttack, buffValue: buffAttack,
                              maxValue: statMax, baseColor: .systemBlue, buffColor: .systemGreen)
        }
        
        if let defensePV = control.defenseProgressView {
            let baseDefense = Float(toki.baseStats.defense)
            let buffDefense = totalEquipmentBuff(for: "defense")
            updateProgressBar(defensePV, baseValue: baseDefense, buffValue: buffDefense,
                              maxValue: statMax, baseColor: .systemBlue, buffColor: .systemGreen)
        }
        
        if let speedPV = control.speedProgressView {
            let baseSpeed = Float(toki.baseStats.speed)
            let buffSpeed = totalEquipmentBuff(for: "speed")
            updateProgressBar(speedPV, baseValue: baseSpeed, buffValue: buffSpeed, maxValue: statMax, baseColor: .systemBlue, buffColor: .systemGreen)
        }
        
        // For heal, if no equipment buffs apply, simply set progress:
        control.healProgressView?.progress = Float(toki.baseStats.heal) / statMax
        
        // Set a tint color for hp if desired.
        control.hpProgressView?.progressTintColor = .systemRed
        
        control.equipmentTableView?.reloadData()
        control.skillsTableView?.reloadData()
    }
    
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int, _ control: TokiDisplayViewController) -> Int {
        // Calculate total slots: base slot (1) + extra slot per 5 levels
        let baseSlots = 1
        let extraSlots = toki.level / 5  // integer division
        let totalSlots = baseSlots + extraSlots
        
        if tableView == control.equipmentTableView {
            // Return the greater of totalSlots or the number of equipments already added
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
                // Configure cell with existing equipment
                let equipmentItem = toki.equipment[indexPath.row]
                cell.nameLabel.text = equipmentItem.name
                cell.itemImageView.image = UIImage(named: equipmentItem.name) // if asset name matches
                // Add long press gesture recognizer for filled equipment cell
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(control.handleEquipmentLongPress(_:)))
                cell.addGestureRecognizer(longPress)
            } else {
                // Empty slot
                cell.nameLabel.text = "Empty Slot"
                cell.itemImageView.image = UIImage(named: "empty") // use an appropriate placeholder image if available
                // Add long press gesture recognizer for empty equipment slot
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(control.handleEquipmentLongPress(_:)))
                cell.addGestureRecognizer(longPress)
            }
        } else { // skillsTableView
            if indexPath.row < toki.skills.count {
                let skillItem = toki.skills[indexPath.row]
                cell.nameLabel.text = skillItem.name
                cell.itemImageView.image = UIImage(named: skillItem.name)
                // Add long press gesture recognizer for filled skill cell
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(control.handleSkillLongPress(_:)))
                cell.addGestureRecognizer(longPress)
            } else {
                // Empty slot for skills
                cell.nameLabel.text = "Empty Slot"
                cell.itemImageView.image = UIImage(named: "empty")
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(control.handleSkillLongPress(_:)))
                cell.addGestureRecognizer(longPress)
            }
        }
        
        return cell
    }
    
    func changeEquipmentTapped(_ sender: UIButton, _ control: TokiDisplayViewController) {
        guard let indexPath = control.equipmentTableView?.indexPathForSelectedRow else {
            let noSelectionAlert = UIAlertController(title: "No Selection",
                                                     message: "Please select an equipment cell to change.", preferredStyle: .alert)
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(noSelectionAlert, animated: true)
            return
        }
        
        // List of candidate equipment names
        let candidateNames = ["Magic Staff 2", "Ice Sword", "Wind Dagger"]
        
        let alert = UIAlertController(title: "Change Equipment", message: "Select a new equipment",
                                      preferredStyle: .actionSheet)
        
        for candidate in candidateNames {
            alert.addAction(UIAlertAction(title: candidate, style: .default, handler: { _ in
                let newEquipment = self.createTestEquipment(name: candidate)
                // Check if the candidate already exists
                if self.toki.equipment.contains(where: { $0.name == newEquipment.name }) {
                    let existsAlert = UIAlertController(title: "Already Exists",
                                                        message: "Equipment \(newEquipment.name) already exists.",
                                                        preferredStyle: .alert)
                    existsAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    control.present(existsAlert, animated: true)
                } else {
                    if indexPath.row < self.toki.equipment.count {
                        // Replace existing equipment
                        self.toki.equipment[indexPath.row] = newEquipment
                    } else {
                        // Insert at empty slot (append)
                        self.toki.equipment.append(newEquipment)
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
    
    func changeSkillsTapped(_ sender: UIButton, _ control: TokiDisplayViewController) {
        guard let indexPath = control.skillsTableView?.indexPathForSelectedRow else {
            let noSelectionAlert = UIAlertController(title: "No Selection", message: "Please select a skill cell to change.", preferredStyle: .alert)
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(noSelectionAlert, animated: true)
            return
        }
        
        // List of candidate skill names
        let candidateNames = ["Thunder Strike 2", "Blaze Kick", "Aqua Jet"]
        
        let alert = UIAlertController(title: "Change Skill", message: "Select a new skill", preferredStyle: .actionSheet)
        
        for candidate in candidateNames {
            alert.addAction(UIAlertAction(title: candidate, style: .default, handler: { _ in
                let newSkill = self.createTestSkill(name: candidate)
                if self.toki.skills.contains(where: { $0.name == newSkill.name }) {
                    let existsAlert = UIAlertController(title: "Already Exists",
                                                        message: "Skill \(newSkill.name) already exists.",
                                                        preferredStyle: .alert)
                    existsAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    control.present(existsAlert, animated: true)
                } else {
                    if indexPath.row < self.toki.skills.count {
                        self.toki.skills[indexPath.row] = newSkill
                    } else {
                        self.toki.skills.append(newSkill)
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
    
    func handleEquipmentLongPress(_ gesture: UILongPressGestureRecognizer, _ control: TokiDisplayViewController) {
        if gesture.state == .began {
            guard let cell = gesture.view as? UITableViewCell,
                  let indexPath = control.equipmentTableView?.indexPath(for: cell) else { return }
            let equipment = toki.equipment[indexPath.row]
            
            // Assume the equipment's first component is a CombinedBuffComponent
            var message = "No buff details available."
            if let buffComponent = equipment.components.first as? CombinedBuffComponent {
                message = "Attack Buff: \(buffComponent.buff.attack)\nDefense Buff:" +
                "\(buffComponent.buff.defense)\nSpeed Buff: \(buffComponent.buff.speed)"
            }
            
            let alert = UIAlertController(title: equipment.name, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(alert, animated: true)
        }
    }

    func handleSkillLongPress(_ gesture: UILongPressGestureRecognizer, _ control: TokiDisplayViewController) {
        if gesture.state == .began {
            guard let cell = gesture.view as? UITableViewCell,
                  let indexPath = control.skillsTableView?.indexPath(for: cell) else { return }
            let skill = toki.skills[indexPath.row]
            
            // Construct a message with skill details. Adjust properties as needed.
            let message = "Description: \(skill.description)\nBase Power: \(skill.basePower)\nCooldown: \(skill.cooldown)"
            
            let alert = UIAlertController(title: skill.name, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(alert, animated: true)
        }
    }
}

