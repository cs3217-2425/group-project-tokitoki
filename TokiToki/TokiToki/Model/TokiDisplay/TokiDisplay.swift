//
//  TokiDisplay.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation
import UIKit

// MARK: - Decodable Data Models for JSON
// These structs mirror the fields in Tokis.json, Skills.json, and Equipments.json,
// just enough to parse raw JSON into intermediate model objects. Then we'll map them to your actual Toki, Skill, and Equipment.

struct TokiJSON: Decodable {
    let id: String
    let name: String
    let rarity: Int
    let baseHealth: Int
    let baseAttack: Int
    let baseDefense: Int
    let baseSpeed: Int
    let baseHeal: Int
    let baseExp: Int
    let elementType: String
}

struct TokisWrapper: Decodable {
    let tokis: [TokiJSON]
}

struct SkillJSON: Decodable {
    let id: String
    let name: String
    let description: String
    let rarity: Int
    let skillType: String
    let targetType: String
    let elementType: String
    let basePower: Int
    let cooldown: Int
    let statusEffectChance: Double
    let statusEffect: String?
    let statusEffectDuration: Int
}

struct SkillsWrapper: Decodable {
    let skills: [SkillJSON]
}

struct ConsumableEffectStrategyJSON: Decodable {
    let type: String // e.g. "potion" or "upgradeCandy"
    let buffValue: Int?
    let duration: Int?
    let statType: String?
    let bonusExp: Int?
}

struct EquipmentBuffJSON: Decodable {
    let value: Int
    let description: String
    let affectedStat: String
}

struct EquipmentJSON: Decodable {
    let id: String
    let name: String
    let description: String
    let equipmentType: String  // "consumable" or "nonConsumable"
    let rarity: Int
    let elementType: String
    let buff: EquipmentBuffJSON?            // Only if nonConsumable
    let effectStrategy: ConsumableEffectStrategyJSON? // Only if consumable
    let slot: String?                       // Only if nonConsumable
}

struct EquipmentsWrapper: Decodable {
    let equipment: [EquipmentJSON]
}

// MARK: - TokiDisplay Class

class TokiDisplay {
    
    // Singleton or shared reference if needed.
    static let shared = TokiDisplay()
    
    // Private storage for “currently viewed” Toki.
    // We need some Toki to attach to the UI, but we’re no longer
    // constructing a test Toki. Instead, we’ll pick one from JSON.
    private var _toki: Toki
    
    // Expose the “current” Toki.
    var toki: Toki {
        get { _toki }
        set { _toki = newValue }
    }
    
    // Optionally keep an array of *all* Tokis loaded from JSON so you can pick which one to display.
    var allTokis: [Toki] = []
    
    // If you want to keep all equipment and skills loaded, store them here.
    // This can be used to show the user a full list or to attach them to a Toki.
    var allEquipment: [Equipment] = []
    var allSkills: [Skill] = []
    
    // The advanced facade and other system references remain.
    internal var equipmentFacade = AdvancedEquipmentFacade()
    
    // MARK: - Init
    // We remove the “test constructor” that previously set a “Default Toki”.
    // Instead, we load data from JSON, then pick the first Toki as the “current Toki.”
    
    init() {
        // Temporary placeholder. We’ll override it once we load from JSON.
        let placeholderStats = TokiBaseStats(hp: 1, attack: 1, defense: 1, speed: 1, heal: 1, exp: 0)
        _toki = Toki(name: "Placeholder",
                     rarity: .common,
                     baseStats: placeholderStats,
                     skills: [],
                     equipments: [],
                     elementType: .fire,
                     level: 1)
        
        // Load from JSON
        loadAllData()
        
        // If we have at least one Toki, pick the first as the “current Toki”
        if let firstToki = allTokis.first {
            _toki = firstToki
        }
    }
    
    // MARK: - JSON Loading
    
    /// Load Tokis, Skills, and Equipment from local JSON files.
    /// Adapt the file paths or decoding strategy as appropriate.
    private func loadAllData() {
        loadTokisFromJSON()
        loadSkillsFromJSON()
        loadEquipmentsFromJSON()
        
        // Optionally set up any needed crafting recipes, etc.
        setupCraftingRecipes()
    }
    
    private func loadTokisFromJSON() {
        guard let url = Bundle.main.url(forResource: "Tokis", withExtension: "json") else {
            print("Tokis.json not found in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(TokisWrapper.self, from: data)
            self.allTokis = decoded.tokis.map { convertToToki($0) }
            print("Tokis loaded: \(self.allTokis.count)")
        } catch {
            print("Failed to parse Tokis.json: \(error)")
        }
    }
    
    private func loadSkillsFromJSON() {
        guard let url = Bundle.main.url(forResource: "Skills", withExtension: "json") else {
            print("Skills.json not found in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(SkillsWrapper.self, from: data)
            self.allSkills = decoded.skills.map { convertToSkill($0) }
            print("Skills loaded: \(self.allSkills.count)")
        } catch {
            print("Failed to parse Skills.json: \(error)")
        }
    }
    
    private func loadEquipmentsFromJSON() {
        guard let url = Bundle.main.url(forResource: "Equipments", withExtension: "json") else {
            print("Equipments.json not found in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(EquipmentsWrapper.self, from: data)
            self.allEquipment = decoded.equipment.compactMap { convertToEquipment($0) }
            print("Equipments loaded: \(self.allEquipment.count)")
        } catch {
            print("Failed to parse Equipments.json: \(error)")
        }
    }
    
    // MARK: - Converters from JSON to your app’s real Toki/Skill/Equipment
    
    private func convertToToki(_ json: TokiJSON) -> Toki {
         // Use the new ItemRarity initializer.
         let rarityEnum = ItemRarity(intValue: json.rarity) ?? .common
         // Convert string to ElementType using fromString.
         let elementEnum = ElementType.fromString(json.elementType) ?? .fire
         
         let stats = TokiBaseStats(hp: json.baseHealth,
                                   attack: json.baseAttack,
                                   defense: json.baseDefense,
                                   speed: json.baseSpeed,
                                   heal: json.baseHeal,
                                   exp: json.baseExp)
         
         // Create a Toki with empty skills and equipment; attach later as needed.
         return Toki(name: json.name,
                     rarity: rarityEnum,
                     baseStats: stats,
                     skills: [],
                     equipments: [],
                     elementType: elementEnum,
                     level: 1)
     }
    
    private func convertToSkill(_ json: SkillJSON) -> Skill {
         // Use the new ElementType conversion.
         let elemType = ElementType.fromString(json.elementType) ?? .neutral
         
         let factory = SkillFactory()
         
         switch json.skillType.lowercased() {
         case "attack":
             return factory.createAttackSkill(
                 name: json.name,
                 description: json.description,
                 elementType: elemType,
                 basePower: json.basePower,
                 cooldown: json.cooldown,
                 targetType: convertTargetType(json.targetType),
                 statusEffect: convertStatusEffect(json.statusEffect),
                 statusEffectChance: Double(json.statusEffectChance),
                 statusEffectDuration: json.statusEffectDuration
             )
         case "heal":
             return factory.createHealSkill(
                 name: json.name,
                 description: json.description,
                 basePower: json.basePower,
                 cooldown: json.cooldown,
                 targetType: convertTargetType(json.targetType)
             )
         case "defend":
             return factory.createDefenseSkill(
                name: json.name,
                description: json.description,
                basePower: json.basePower,
                cooldown: json.cooldown,
                targetType: convertTargetType(json.targetType)
             )
         default:
             return factory.createAttackSkill(
                 name: json.name,
                 description: json.description,
                 elementType: elemType,
                 basePower: json.basePower,
                 cooldown: json.cooldown,
                 targetType: .singleEnemy,
                 statusEffect: .none,
                 statusEffectChance: 0.0,
                 statusEffectDuration: 0
             )
         }
     }
     
    
    private func convertToEquipment(_ json: EquipmentJSON) -> Equipment? {
         let repo = EquipmentRepository.shared
         let rarity = json.rarity
         let desc = json.description
         
         if json.equipmentType == "consumable", let strategyInfo = json.effectStrategy {
             let strategy: ConsumableEffectStrategy
             switch strategyInfo.type.lowercased() {
             case "potion":
                 let buff = strategyInfo.buffValue ?? 0
                 let durSec = TimeInterval(strategyInfo.duration ?? 0)
                 strategy = PotionEffectStrategy(buffValue: buff, duration: durSec)
             case "upgradecandy":
                 let bonus = strategyInfo.bonusExp ?? 0
                 strategy = UpgradeCandyEffectStrategy(bonusExp: bonus)
             default:
                 strategy = UpgradeCandyEffectStrategy(bonusExp: 0)
             }
             
             return repo.createConsumableEquipment(
                 name: json.name,
                 description: desc,
                 rarity: rarity,
                 effectStrategy: strategy,
                 usageContext: .outOfBattleOnly
             )
         } else if json.equipmentType == "nonConsumable", let buffInfo = json.buff, let slotName = json.slot {
             let buff = EquipmentBuff(value: buffInfo.value,
                                      description: buffInfo.description,
                                      affectedStat: buffInfo.affectedStat)
             let slotEnum = EquipmentSlot(rawValue: slotName) ?? .custom
             
             return repo.createNonConsumableEquipment(
                 name: json.name,
                 description: desc,
                 rarity: rarity,
                 buff: buff,
                 slot: slotEnum
             )
         }
         return nil
     }
    
    /// Example converters for skill target type and status effect
    private func convertTargetType(_ raw: String) -> TargetType {
        switch raw.lowercased() {
        case "singleenemy": return .singleEnemy
        case "allallies": return .allAllies
        case "allenemies": return .allEnemies
        case "ownself": return .ownself
        default: return .singleEnemy
        }
    }
    
    private func convertStatusEffect(_ raw: String?) -> StatusEffectType {
        guard let raw = raw else { return .attackBuff }
        switch raw.lowercased() {
        case "burn": return .burn
        case "paralysis": return .paralysis
        case "defensebuff": return .defenseBuff
        default: return .attackBuff
        }
    }


    // MARK: - Reuse existing methods: (UI updating, recipes, etc.)
    
    /// Registers sample crafting recipes (same as original).
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
                                           effectStrategy: newStrategy,
                                           usageContext: .outOfBattleOnly)
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
    
    /// Returns current inventory/equipped state for UI display.
    func currentState() -> (inventory: String, equipped: String) {
        let component = equipmentFacade.equipmentComponent
        let inventoryNames = component.inventory
            .map { "\($0.name)(\($0.equipmentType == .consumable ? "C" : "N"))" }
            .joined(separator: ", ")
        let equippedNames = component.equipped
            .map { "\($0.key.rawValue): \($0.value.name)" }
            .joined(separator: ", ")
        return (inventoryNames, equippedNames)
    }
    
    func undoLastAction() {
        equipmentFacade.undoLastAction()
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
            updateProgressBar(speedPV, baseValue: baseSpeed, buffValue: buffSpeed,
                              maxValue: statMax, baseColor: .systemBlue, buffColor: .systemGreen)
        }
        
        control.healProgressView?.progress = Float(toki.baseStats.heal) / statMax
        control.hpProgressView?.progressTintColor = .systemRed
        control.equipmentTableView?.reloadData()
        control.skillsTableView?.reloadData()
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
        
        // Build an action sheet using all equipment loaded from JSON.
        let alert = UIAlertController(title: "Change Equipment", message: "Select a new equipment", preferredStyle: .actionSheet)
        
        // Iterate over allEquipment array loaded from JSON.
        for equipment in self.allEquipment {
            alert.addAction(UIAlertAction(title: equipment.name, style: .default, handler: { _ in
                // Check if this equipment is already part of the Toki's equipments.
                if self.toki.equipment.contains(where: { $0.id == equipment.id }) {
                    let existsAlert = UIAlertController(title: "Already Exists",
                                                        message: "Equipment \(equipment.name) already exists.",
                                                        preferredStyle: .alert)
                    existsAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    control.present(existsAlert, animated: true)
                } else {
                    if indexPath.row < self.toki.equipment.count {
                        self.toki.equipment[indexPath.row] = equipment
                    } else {
                        self.toki.equipment.append(equipment)
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
        
        // Build an action sheet using all skills loaded from JSON.
        let alert = UIAlertController(title: "Change Skill", message: "Select a new skill", preferredStyle: .actionSheet)
        
        // Iterate over allSkills array loaded from JSON.
        for skill in self.allSkills {
            alert.addAction(UIAlertAction(title: skill.name, style: .default, handler: { _ in
                // Check if this skill is already part of the Toki's skills.
                if self.toki.skills.contains(where: { $0.id == skill.id }) {
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

// TODO: Create a entry display to show all the tokis (get tokis from json). On entry into TokiDisplay, load the toki, the equipment and skills from json.
// TODO: Remove the test constructor and load the data from json.

