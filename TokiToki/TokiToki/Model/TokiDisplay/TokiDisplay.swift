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

struct TokiJSON: Codable {
    let id: String
    let name: String
    let level: Int
    let rarity: Int
    let elementType: [String]
    let ownerId: String
    let baseStats: BaseStatsJSON
    let skillNames: [String]
    let equipmentIds: [String]
}

struct BaseStatsJSON: Codable {
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
    let heal: Int
    let exp: Int
    let critHitChance: Int
    let critHitDamage: Int
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
    let skills: [SkillData]
}

struct ConsumableEffectStrategyJSON: Decodable {
    let type: String // e.g. "potion" or "upgradeCandy"
    let buffValue: Int?
    let duration: Int?
    let statType: String?
    let bonusExp: Int?
}

struct EquipmentJSON: Codable {
    let id: String
    let name: String
    let description: String
    let rarity: Int
    let equipmentType: String
    let ownerId: String
    let isEquipped: Bool?
    let slot: String?
    let buff: BuffJSON?
    let effectStrategy: EffectStrategyJSON?
    let usageContext: String?
}

struct BuffJSON: Codable {
    let value: Int
    let description: String
    let affectedStat: String
}

struct EffectStrategyJSON: Codable {
    let type: String
    let buffValue: Int?
    let duration: Double?
    let bonusExp: Int?
}

struct CraftingRecipeJSON: Decodable {
    let type: String
    let requiredEquipmentIdentifiers: [String]
    let resultName: String
    let description: String
    let rarityIncrement: Int
    let slot: String?         // Only for non-consumable recipes
    let usageContext: String? // Only for consumable recipes
}

struct CraftingRecipesWrapper: Decodable {
    let recipes: [CraftingRecipeJSON]
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
    var allSkills: [Skill] = []
    var allEquipment: [Equipment] = []

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
                     elementType: [.fire],
                     level: 1)

        // Load from JSON
        loadAllData()

        // If we have at least one Toki, pick the first as the “current Toki”
        if let firstToki = allTokis.first {
            _toki = firstToki
        }
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
        for equip in toki.equipments {
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

        control.elementLabel?.text = "Element: \(toki.elementType.map(\.description).joined(separator: ", "))"
      
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
}
