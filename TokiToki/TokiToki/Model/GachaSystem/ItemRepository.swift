//
//  ItemRepository.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//

import Foundation

class ItemRepository {
    // Templates loaded from JSON
    private var tokiTemplates: [String: TokiData] = [:]
    private var skillTemplates: [String: SkillData] = [:]
    private var equipmentTemplates: [String: EquipmentData] = [:]
    
    // Factory objects
    private let skillFactory = SkillFactory()
    private let equipmentRepository = EquipmentRepository.shared
    
    init() {
        loadTemplatesFromJSON()
    }
    
    // MARK: - Data Initialization
    
    private func loadTemplatesFromJSON() {
        loadTokiTemplates()
        loadSkillTemplates()
        loadEquipmentTemplates()
    }
    
    private func loadTokiTemplates() {
        do {
            let tokisData: TokisData = try ResourceLoader.loadJSON(fromFile: "Tokis")
            
            for tokiData in tokisData.tokis {
                tokiTemplates[tokiData.name] = tokiData
            }
            
            print("Loaded \(tokiTemplates.count) Toki templates from JSON")
        } catch {
            print("Error loading Toki templates: \(error)")
        }
    }
    
    private func loadSkillTemplates() {
        do {
            let skillsData: SkillsData = try ResourceLoader.loadJSON(fromFile: "Skills")
            
            for skillData in skillsData.skills {
                skillTemplates[skillData.name] = skillData
            }
            
            print("Loaded \(skillTemplates.count) Skill templates from JSON")
        } catch {
            print("Error loading Skill templates: \(error)")
        }
    }
    
    private func loadEquipmentTemplates() {
        do {
            let equipmentsData: EquipmentsData = try ResourceLoader.loadJSON(fromFile: "Equipments")
            
            for equipmentData in equipmentsData.equipment {
                equipmentTemplates[equipmentData.name] = equipmentData
            }
            
            print("Loaded \(equipmentTemplates.count) Equipment templates from JSON")
        } catch {
            print("Error loading Equipment templates: \(error)")
        }
    }
    
    // MARK: - Template Access Methods
    
    func getTokiTemplate(name: String) -> TokiData? {
        return tokiTemplates[name]
    }
    
    func getSkillTemplate(name: String) -> SkillData? {
        return skillTemplates[name]
    }
    
    func getEquipmentTemplate(name: String) -> EquipmentData? {
        return equipmentTemplates[name]
    }
    
    func getAllTokiTemplates() -> [TokiData] {
        return Array(tokiTemplates.values)
    }
    
    func getAllSkillTemplates() -> [SkillData] {
        return Array(skillTemplates.values)
    }
    
    func getAllEquipmentTemplates() -> [EquipmentData] {
        return Array(equipmentTemplates.values)
    }
    
    // MARK: - Create Game Objects from Templates
    
    // Create a full Toki object from a template
    func createToki(from template: TokiData) -> Toki {
        let baseStats = TokiBaseStats(
            hp: template.baseHealth,
            attack: template.baseAttack,
            defense: template.baseDefense,
            speed: template.baseSpeed,
            heal: template.baseHeal,
            exp: template.baseExp
        )
        
        // Randomly select some skills and equipment for the Toki
        let skills = selectRandomSkills(count: 2)
        let equipment = selectRandomEquipment(count: 1)
        
        return Toki(
            id: UUID(),
            name: template.name,
            rarity: convertIntToItemRarity(template.rarity),
            baseStats: baseStats,
            skills: [], // TODO: fill up with skills
            equipments: equipment,
            elementType: [convertStringToElement(template.elementType)],
            level: 1
        )
    }
    
    // Create a Skill object from template
    private func createSkill(from template: SkillData) -> Skill? {
        // First, analyze the structure to determine which factory method to use
        if template.effectDefinitions.count == 1 {
            // Single effect definition cases
            let effectDef = template.effectDefinitions[0]
            let targetType = convertStringToTargetType(effectDef.targetType)
            
            if targetType == .singleEnemy {
                // Check for calculators
                let hasAttack = effectDef.calculators.contains { $0.calculatorType.lowercased() == "attack" }
                let hasStatusEffect = effectDef.calculators.contains { $0.calculatorType.lowercased() == "statuseffect" }
                let hasStatsModifier = effectDef.calculators.contains { $0.calculatorType.lowercased() == "statsmodifier" }
                
                // Extract attack calculator data
                let attackCalc = effectDef.calculators.first { $0.calculatorType.lowercased() == "attack" }
                guard let attackCalc = attackCalc,
                      let elementTypeStr = attackCalc.elementType,
                      let basePower = attackCalc.basePower else {
                    // If no valid attack calculator, return nil
                    return nil
                }
                
                let elementType = convertStringToElement(elementTypeStr)
                
                if hasAttack && hasStatusEffect {
                    // Single target attack with status effect
                    let statusCalc = effectDef.calculators.first { $0.calculatorType.lowercased() == "statuseffect" }
                    guard let statusCalc = statusCalc,
                          let statusEffectChance = statusCalc.statusEffectChance,
                          let statusEffectStr = statusCalc.statusEffect else {
                        // Fall back to basic attack if status effect details missing
                        return skillFactory.createBasicSingleTargetDmgSkill(
                            name: template.name,
                            description: template.description,
                            cooldown: template.cooldown,
                            elementType: elementType,
                            basePower: basePower
                        )
                    }
                    
                    let statusEffect = convertStringToStatusEffect(statusEffectStr)
                    let duration = statusCalc.statusEffectDuration ?? 1
                    let strength = statusCalc.statusEffectStrength ?? 1.0
                    
                    return skillFactory.createSingleTargetDmgSkillWithStatusEffect(
                        name: template.name,
                        description: template.description,
                        cooldown: template.cooldown,
                        elementType: elementType,
                        basePower: basePower,
                        statusEffectChance: statusEffectChance,
                        statusEffect: statusEffect,
                        statusEffectDuration: duration,
                        statusEffectStrength: strength
                    )
                } else if hasAttack && hasStatsModifier {
                    // Single target attack with debuff
                    let statsCalc = effectDef.calculators.first { $0.calculatorType.lowercased() == "statsmodifier" }
                    guard let statsCalc = statsCalc else {
                        // Fall back to basic attack if stats modifier missing
                        return skillFactory.createBasicSingleTargetDmgSkill(
                            name: template.name,
                            description: template.description,
                            cooldown: template.cooldown,
                            elementType: elementType,
                            basePower: basePower
                        )
                    }
                    
                    let duration = statsCalc.statsModifierDuration ?? 1
                    let attackMod = statsCalc.attackModifier ?? 1.0
                    let defenseMod = statsCalc.defenseModifier ?? 1.0
                    let speedMod = statsCalc.speedModifier ?? 1.0
                    let healMod = statsCalc.healModifier ?? 1.0
                    
                    return skillFactory.createSingleTargetDmgSkillWithDebuff(
                        name: template.name,
                        description: template.description,
                        cooldown: template.cooldown,
                        elementType: elementType,
                        basePower: basePower,
                        duration: duration,
                        attack: attackMod,
                        defense: defenseMod,
                        speed: speedMod,
                        heal: healMod
                    )
                } else {
                    // Basic single target attack
                    return skillFactory.createBasicSingleTargetDmgSkill(
                        name: template.name,
                        description: template.description,
                        cooldown: template.cooldown,
                        elementType: elementType,
                        basePower: basePower
                    )
                }
            }
        } else if template.effectDefinitions.count == 2 {
            // Check for attack + self buff pattern
            let firstEffectDef = template.effectDefinitions[0]
            let secondEffectDef = template.effectDefinitions[1]
            
            let firstTargetType = convertStringToTargetType(firstEffectDef.targetType)
            let secondTargetType = convertStringToTargetType(secondEffectDef.targetType)
            
            if (firstTargetType == .singleEnemy && secondTargetType == .ownself) {
                // Extract attack calculator data
                let attackCalc = firstEffectDef.calculators.first { $0.calculatorType.lowercased() == "attack" }
                guard let attackCalc = attackCalc,
                      let elementTypeStr = attackCalc.elementType,
                      let basePower = attackCalc.basePower else {
                    return nil
                }
                
                // Extract stats modifier data
                let statsCalc = secondEffectDef.calculators.first { $0.calculatorType.lowercased() == "statsmodifier" }
                guard let statsCalc = statsCalc else {
                    return nil
                }
                
                let elementType = convertStringToElement(elementTypeStr)
                let duration = statsCalc.statsModifierDuration ?? 1
                let attackMod = statsCalc.attackModifier ?? 1.0
                let defenseMod = statsCalc.defenseModifier ?? 1.0
                let speedMod = statsCalc.speedModifier ?? 1.0
                let healMod = statsCalc.healModifier ?? 1.0
                
                return skillFactory.createSingleTargetDmgSkillAndBuffSelf(
                    name: template.name,
                    description: template.description,
                    cooldown: template.cooldown,
                    elementType: elementType,
                    basePower: basePower,
                    duration: duration,
                    attack: attackMod,
                    defense: defenseMod,
                    speed: speedMod,
                    heal: healMod
                )
            }
        }
        
        // Fall back to creating a basic skill if we can't match any pattern
        let elementType = ElementType.neutral
        let basePower =  0
        
        return skillFactory.createBasicSingleTargetDmgSkill(
            name: template.name,
            description: template.description,
            cooldown: template.cooldown,
            elementType: elementType,
            basePower: basePower
        )
    }
    
    // Create an Equipment object from template
    func createEquipment(from template: EquipmentData) -> Equipment {
        // Check equipment type
        if template.equipmentType.lowercased() == "consumable" {
            // For consumable equipment
            guard let effectData = template.effectStrategy else {
                // Fallback for consumable with no effect strategy
                let potionStrategy = PotionEffectStrategy(buffValue: 10, duration: 30.0)
                return equipmentRepository.createConsumableEquipment(
                    name: template.name,
                    description: template.description,
                    rarity: template.rarity,
                    effectStrategy: potionStrategy
                )
            }
            
            // Create effect strategy based on type
            let effectStrategy = createEffectStrategy(from: effectData)
            return equipmentRepository.createConsumableEquipment(
                name: template.name,
                description: template.description,
                rarity: template.rarity,
                effectStrategy: effectStrategy
            )
        } else {
            // For non-consumable equipment
            guard let buffData = template.buff, let slot = template.slot else {
                // Fallback for non-consumable with no buff or slot
                let defaultStatBuff = StatBuff(attack: 0, defense: 0, speed: 0, description: "No stat boost")
                return equipmentRepository.createNonConsumableEquipment(
                    name: template.name,
                    description: template.description,
                    rarity: template.rarity,
                    buff: defaultStatBuff,
                    slot: .weapon
                )
            }
            
            // Create StatBuff based on affected stat
            let statBuff: StatBuff
            switch buffData.affectedStat.lowercased() {
            case "attack":
                statBuff = StatBuff(attack: buffData.value, defense: 0, speed: 0, description: "Attack boost")
            case "defense":
                statBuff = StatBuff(attack: 0, defense: buffData.value, speed: 0, description: "Defense boost")
            case "speed":
                statBuff = StatBuff(attack: 0, defense: 0, speed: buffData.value, description: "Speed boost")
            default:
                statBuff = StatBuff(attack: 0, defense: 0, speed: 0, description: "No stat boost")
            }
            
            let equipmentSlot = convertStringToEquipmentSlot(slot)
            
            return equipmentRepository.createNonConsumableEquipment(
                name: template.name,
                description: template.description,
                rarity: template.rarity,
                buff: statBuff,
                slot: equipmentSlot
            )
        }
    }
    
    // MARK: - Helper Methods for Creating Random Collections
    
    private func selectRandomSkills(count: Int) -> [Skill] {
        let templates = Array(skillTemplates.values)
        guard !templates.isEmpty else { return [] }
        
        var selectedSkills: [Skill] = []
        for _ in 0..<min(count, templates.count) {
            if let template = templates.randomElement() {
                if let skill = createSkill(from: template) {
                    selectedSkills.append(skill)
                }
            }
        }
        
        return selectedSkills
    }
    
    
    // Select random equipment for a newly drawn Toki
    private func selectRandomEquipment(count: Int) -> [Equipment] {
        let templates = Array(equipmentTemplates.values)
        guard !templates.isEmpty else { return [] }
        
        var selectedEquipment: [Equipment] = []
        for _ in 0..<min(count, templates.count) {
            if let template = templates.randomElement() {
                let equipment = createEquipment(from: template)
                selectedEquipment.append(equipment)
            }
        }
        
        return selectedEquipment
    }
    
    // Helper to create consumable effect strategy
    private func createEffectStrategy(from effectData: EquipmentData.EffectStrategyData) -> ConsumableEffectStrategy {
        switch effectData.type.lowercased() {
        case "potion":
            let buffValue = effectData.buffValue ?? 10
            let duration = effectData.duration ?? 30.0
            return PotionEffectStrategy(buffValue: buffValue, duration: duration)
        case "upgradecandy":
            let bonusExp = effectData.bonusExp ?? 100
            return UpgradeCandyEffectStrategy(bonusExp: bonusExp)
        default: return PotionEffectStrategy(buffValue: 10, duration: 30.0)
        }
    }
    
    // MARK: - Type Conversion Helpers
    
    private func convertStringToElement(_ str: String) -> ElementType {
        switch str.lowercased() {
        case "fire": return .fire
        case "water": return .water
        case "earth": return .earth
        case "air": return .air
        case "light": return .light
        case "dark": return .dark
        default: return .neutral
        }
    }
    
    private func convertIntToItemRarity(_ value: Int) -> ItemRarity {
        if let rarity = ItemRarity(intValue: value) {
            return rarity
        }
        return .common
    }
    
    private func convertStringToSkillType(_ str: String) -> SkillType {
        switch str.lowercased() {
        case "attack": return .attack
        case "heal": return .heal
        default: return .attack
        }
    }
    
    private func convertStringToTargetType(_ str: String) -> TargetType {
        switch str.lowercased() {
        case "singleenemy": return .singleEnemy
        case "all": return .all
        case "ownself": return .ownself
        case "allallies": return .allAllies
        case "allenemies": return .allEnemies
        case "singleally": return .singleAlly
        default: return .singleEnemy
        }
    }
    
    private func convertStringToStatusEffect(_ str: String) -> StatusEffectType? {
        switch str.lowercased() {
        case "stun": return .stun
        case "poison": return .poison
        case "burn": return .burn
        case "frozen": return .frozen
        case "paralysis": return .paralysis
        default: return nil
        }
    }
    
    private func convertStringToEquipmentSlot(_ str: String) -> EquipmentSlot {
        switch str.lowercased() {
        case "weapon": return .weapon
        case "armor": return .armor
        case "accessory": return .accessory
        default: return .weapon
        }
    }
    
    
}
