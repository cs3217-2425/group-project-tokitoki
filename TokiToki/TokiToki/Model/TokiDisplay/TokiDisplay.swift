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
    private var _toki: Toki
    private var equipmentFacade = AdvancedEquipmentFacade()

    var toki: Toki {
        get { return _toki }
        set { _toki = newValue }
    }
    
    required init() {
        self._toki = Toki(name: "Default Toki",
                         rarity: .common,
                         baseStats: TokiBaseStats(hp: 100, attack: 50, defense: 50, speed: 50, heal: 100, exp: 42),
                         skills: [],
                         equipments: [],
                         elementType: .fire,
                         level: 1)
    }
    
    private func createTestSkill(name: String = "Thunder Strike") -> Skill {
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
        // Use EquipmentRepository instead of EquipmentFactory.
        let repository = EquipmentRepository.shared
        // Here, assume that the equipment's elementType is provided by the repository
        // and that Buff is replaced by EquipmentBuff.
        // For compatibility with legacy code, we'll create a dummy EquipmentBuff.
        let dummyBuff = EquipmentBuff(value: 10, description: "Magical buff", affectedStat: "attack")
        let equipment = repository.createNonConsumableEquipment(name: name,
                                                                description: "A magical staff",
                                                                rarity: 1,
                                                                buff: dummyBuff,
                                                                slot: .custom)
        return equipment
    }
    
    /// Registers sample crafting recipes.
    func setupCraftingRecipes() {
        let potionRecipe = CraftingRecipe(requiredEquipmentIdentifiers: ["health potion", "health potion"]) { (equipments: [Equipment]) in
            if let potion1 = equipments[0] as? ConsumableEquipment,
               let potion2 = equipments[1] as? ConsumableEquipment,
               let strat1 = potion1.effectStrategy as? PotionEffectStrategy,
               let strat2 = potion2.effectStrategy as? PotionEffectStrategy {
                let newBuff = strat1.buffValue + strat2.buffValue
                let newDuration = (strat1.duration + strat2.duration) / 2
                let newStrategy = PotionEffectStrategy(buffValue: newBuff, duration: newDuration)
                return ConsumableEquipment(name: "Super Health Potion",
                                           description: "A crafted potion with enhanced effects.",
                                           rarity: max(potion1.rarity, potion2.rarity) + 1,
                                           effectStrategy: newStrategy)
            }
            return nil
        }
        
        let weaponRecipe = CraftingRecipe(requiredEquipmentIdentifiers: ["sword", "sword"]) { (equipments: [Equipment]) in
            if let weapon1 = equipments[0] as? NonConsumableEquipment,
               let weapon2 = equipments[1] as? NonConsumableEquipment {
                let combinedBuff = EquipmentBuff(value: weapon1.buff.value + weapon2.buff.value,
                                                 description: "Enhanced combined weapon buff",
                                                 affectedStat: "attack")
                return NonConsumableEquipment(name: "Dual Sword",
                                              description: "A crafted weapon combining two swords.",
                                              rarity: max(weapon1.rarity, weapon2.rarity) + 1,
                                              buff: combinedBuff,
                                              slot: .weapon)
            }
            return nil
        }
        
        ServiceLocator.shared.craftingManager.register(recipe: potionRecipe)
        ServiceLocator.shared.craftingManager.register(recipe: weaponRecipe)
    }
    
    /// Returns the current equipment state for display purposes.
    func currentState() -> (inventory: String, equipped: String) {
        let component = equipmentFacade.equipmentComponent
        let inventoryNames = component.inventory.map { "\($0.name)(\($0.equipmentType == .consumable ? "C" : "N"))" }
            .joined(separator: ", ")
        let equippedNames = component.equipped.map { "\($0.key.rawValue): \($0.value.name)" }
            .joined(separator: ", ")
        return (inventoryNames, equippedNames)
    }
    
    /// Loads sample equipment into the system.
    func loadSampleEquipment() {
        let repository = EquipmentRepository.shared
        
        let potionStrategy = PotionEffectStrategy(buffValue: 10, duration: 5)
        let healthPotion = repository.createConsumableEquipment(name: "Health Potion",
                                                                description: "Restores health temporarily.",
                                                                rarity: 1,
                                                                effectStrategy: potionStrategy)
        
        let upgradeCandyStrategy = UpgradeCandyEffectStrategy(bonusExp: 50)
        let upgradeCandy = repository.createConsumableEquipment(name: "Upgrade Candy",
                                                                description: "Grants bonus EXP permanently.",
                                                                rarity: 1,
                                                                effectStrategy: upgradeCandyStrategy)
        
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
        if let consumable = component.inventory.first(where: { $0.equipmentType == .consumable }) as? ConsumableEquipment {
            let toki = Toki(name: "Demo Toki", rarity: .common, baseStats: TokiBaseStats(hp: 100, attack: 50, defense: 50, speed: 50, heal: 100, exp: 42), skills: [], equipments: [], elementType: .fire, level: 1)
            equipmentFacade.useConsumable(consumable: consumable, on: toki)
        }
    }
    
    /// Undoes the last equipment action.
    func undoLastAction() {
        equipmentFacade.undoLastAction()
    }
    
    func loadTest() {
        let skill = createTestSkill()
        let equipment = createTestEquipment()
        self.toki = Toki(name: "Tokimon Omicron 1",
                         rarity: .common,
                         baseStats: TokiBaseStats(hp: 100, attack: 50, defense: 50, speed: 50, heal: 100, exp: 492),
                         skills: [skill],
                         equipments: [equipment],
                         elementType: .fire,
                         level: 1)
    }
    
    private func totalEquipmentBuff(for stat: String) -> Float {
        var total: Float = 0
        for equip in toki.equipment {
            // Use the extension property 'components' from NonConsumableEquipment
            if let comp = (equip as? NonConsumableEquipment)?.components.first as? CombinedBuffComponent {
                switch stat {
                case "attack":
                    total += Float(comp.buff.attack)
                case "defense":
                    total += Float(comp.buff.defense)
                case "speed":
                    total += Float(comp.buff.speed)
                default:
                    break
                }
            }
        }
        return total
    }
    
    private func updateProgressBar(_ progressView: UIProgressView, baseValue: Float,
                                   buffValue: Float, maxValue: Float, baseColor: UIColor, buffColor: UIColor) {
        progressView.subviews.forEach { $0.removeFromSuperview() }
        let totalValue = baseValue + buffValue
        let baseRatio = totalValue > 0 ? baseValue / maxValue : 0
        let buffRatio = totalValue > 0 ? buffValue / maxValue : 0
        let totalWidth = progressView.bounds.width
        let height = progressView.bounds.height
        let baseWidth = totalWidth * CGFloat(baseRatio)
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: baseWidth, height: height))
        baseView.backgroundColor = baseColor
        progressView.addSubview(baseView)
        let buffWidth = totalWidth * CGFloat(buffRatio)
        let buffView = UIView(frame: CGRect(x: baseWidth, y: 0, width: buffWidth, height: height))
        buffView.backgroundColor = buffColor
        progressView.addSubview(buffView)
    }
    
    func updateUI(_ control: TokiDisplayViewController) {
        control.tokiImageView?.image = UIImage(named: toki.name)
        control.nameLabel?.text = toki.name
        control.levelLabel?.text = "Level: \(toki.level)"
        control.hpLabel?.text = "HP: \(toki.baseStats.hp)"
        control.expLabel?.text = "Experience: \(toki.baseStats.exp)"
        control.attackLabel?.text = "Attack: \(toki.baseStats.attack + Int(totalEquipmentBuff(for: "attack")))"
        control.defenseLabel?.text = "Defense: \(toki.baseStats.defense + Int(totalEquipmentBuff(for: "defense")))"
        control.healLabel?.text = "Heal: \(toki.baseStats.heal)"
        control.speedLabel?.text = "Speed: \(toki.baseStats.speed + Int(totalEquipmentBuff(for: "speed")))"
        control.rarityLabel?.text = "Rarity: \(toki.rarity)"
        control.elementLabel?.text = "Element: \(toki.elementType)"
        
        let hpMax: Float = 420.0
        let expMax: Float = 100.0
        let statMax: Float = 100.0
        
        control.hpProgressView?.progress = Float(toki.baseStats.hp) / hpMax
        control.expProgressView?.progress = Float(toki.baseStats.exp) / expMax
        
        if let attackPV = control.attackProgressView {
            let baseAttack = Float(toki.baseStats.attack)
            let buffAttack = totalEquipmentBuff(for: "attack")
            updateProgressBar(attackPV, baseValue: baseAttack, buffValue: buffAttack, maxValue: statMax, baseColor: .systemBlue, buffColor: .systemGreen)
        }
        
        if let defensePV = control.defenseProgressView {
            let baseDefense = Float(toki.baseStats.defense)
            let buffDefense = totalEquipmentBuff(for: "defense")
            updateProgressBar(defensePV, baseValue: baseDefense, buffValue: buffDefense, maxValue: statMax, baseColor: .systemBlue, buffColor: .systemGreen)
        }
        
        if let speedPV = control.speedProgressView {
            let baseSpeed = Float(toki.baseStats.speed)
            let buffSpeed = totalEquipmentBuff(for: "speed")
            updateProgressBar(speedPV, baseValue: baseSpeed, buffValue: buffSpeed, maxValue: statMax, baseColor: .systemBlue, buffColor: .systemGreen)
        }
        
        control.healProgressView?.progress = Float(toki.baseStats.heal) / statMax
        control.hpProgressView?.progressTintColor = .systemRed
        control.equipmentTableView?.reloadData()
        control.skillsTableView?.reloadData()
    }
    
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
    
    func changeEquipmentTapped(_ sender: UIButton, _ control: TokiDisplayViewController) {
        guard let indexPath = control.equipmentTableView?.indexPathForSelectedRow else {
            let noSelectionAlert = UIAlertController(title: "No Selection",
                                                     message: "Please select an equipment cell to change.",
                                                     preferredStyle: .alert)
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(noSelectionAlert, animated: true)
            return
        }
        
        let candidateNames = ["Magic Staff 2", "Ice Sword", "Wind Dagger"]
        let alert = UIAlertController(title: "Change Equipment", message: "Select a new equipment", preferredStyle: .actionSheet)
        
        for candidate in candidateNames {
            alert.addAction(UIAlertAction(title: candidate, style: .default, handler: { _ in
                let newEquipment = self.createTestEquipment(name: candidate)
                if self.toki.equipment.contains(where: { $0.name == newEquipment.name }) {
                    let existsAlert = UIAlertController(title: "Already Exists",
                                                        message: "Equipment \(newEquipment.name) already exists.",
                                                        preferredStyle: .alert)
                    existsAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    control.present(existsAlert, animated: true)
                } else {
                    if indexPath.row < self.toki.equipment.count {
                        self.toki.equipment[indexPath.row] = newEquipment
                    } else {
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
            let noSelectionAlert = UIAlertController(title: "No Selection",
                                                     message: "Please select a skill cell to change.",
                                                     preferredStyle: .alert)
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(noSelectionAlert, animated: true)
            return
        }
        
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
            var message = "No buff details available."
            if let buffComponent = (equipment as? NonConsumableEquipment)?.components.first as? CombinedBuffComponent {
                message = "Attack Buff: \(buffComponent.buff.attack)\nDefense Buff: \(buffComponent.buff.defense)\nSpeed Buff: \(buffComponent.buff.speed)"
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
            let message = "Description: \(skill.description)\nBase Power: \(skill.basePower)\nCooldown: \(skill.cooldown)"
            let alert = UIAlertController(title: skill.name, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            control.present(alert, animated: true)
        }
    }
}
