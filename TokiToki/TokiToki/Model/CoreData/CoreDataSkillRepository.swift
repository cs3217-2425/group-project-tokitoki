//
//  SkillRepository.swift
//  TokiToki
//

import CoreData
import Foundation

class CoreDataSkillRepository {
    private let context: NSManagedObjectContext
    private let skillFactory = SkillFactory()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Save Skills
    
    /// Save a skill to Core Data with full effect definition structure
    func saveSkill(_ skill: Skill, ownerId: UUID? = nil) -> SkillCD {
        // Create or retrieve the skill entity
        let skillCD = SkillCD(context: context)
        skillCD.id = UUID() // Create a new UUID for this stored skill
        skillCD.name = skill.name
        skillCD.desc = skill.description
        skillCD.cooldown = Int32(skill.cooldown)
        skillCD.currentCooldown = Int32(skill.currentCooldown)
        skillCD.ownerId = ownerId
        skillCD.dateAcquired = Date()
        

        for effectDef in skill.effectDefinitions {
            let effectDefinitionCD = createEffectDefinitionEntity(effectDef, for: skillCD)
            skillCD.addToEffectDefinitions(effectDefinitionCD)
        }
        
        
        // Save context
        DataManager.shared.saveContext(context)
        
        return skillCD
    }
    
    /// Create an effect definition entity
    private func createEffectDefinitionEntity(_ effectDefinition: EffectDefinition, for skillCD: SkillCD) -> EffectDefinitionCD {
        // Only attempt this if the entity exists in the model
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "EffectDefinitionCD", in: context) else {
            fatalError("EffectDefinitionCD entity not found in model")
        }
        
        let effectDefCD = EffectDefinitionCD(context: context)
        effectDefCD.id = UUID()
        effectDefCD.targetType = targetTypeToString(effectDefinition.targetType)
        
        // Add calculators if the model supports it
        if let _ = NSEntityDescription.entity(forEntityName: "EffectCalculatorCD", in: context) {
            // Add calculators
            for calculator in effectDefinition.effectCalculators {
                let calculatorCD = createEffectCalculatorEntity(calculator)
                effectDefCD.addToCalculators(calculatorCD)
            }
        }
        
        return effectDefCD
    }
    
    /// Create an effect calculator entity
    private func createEffectCalculatorEntity(_ calculator: EffectCalculator) -> EffectCalculatorCD {
        // Only attempt this if the entity exists in the model
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "EffectCalculatorCD", in: context) else {
            fatalError("EffectCalculatorCD entity not found in model")
        }
        
        let calculatorCD = EffectCalculatorCD(context: context)
        calculatorCD.id = UUID()
        
        // Set type and properties based on calculator type
        if let attackCalc = calculator as? AttackCalculator {
            calculatorCD.calculatorType = "attack"
            calculatorCD.elementType = attackCalc.elementType.rawValue
            calculatorCD.basePower = Int32(attackCalc.basePower)
        }
        else if let statusCalc = calculator as? StatusEffectCalculator {
            calculatorCD.calculatorType = "statusEffect"
            calculatorCD.statusEffectChance = statusCalc.statusEffectChance
            if let effect = statusCalc.statusEffect {
                calculatorCD.statusEffect = statusEffectToString(effect)
            }
            calculatorCD.statusEffectDuration = Int32(statusCalc.statusEffectDuration)
            calculatorCD.statusEffectStrength = statusCalc.statusEffectStrength
        }
        else if let statsCalc = calculator as? StatsModifiersCalculator,
                !statsCalc.statsModifiers.isEmpty {
            calculatorCD.calculatorType = "statsModifier"
            
            // Get the first stats modifier
            let statsModifier = statsCalc.statsModifiers[0]
            calculatorCD.statsModifierDuration = Int32(statsModifier.remainingDuration)
            calculatorCD.attackModifier = statsModifier.attack
            calculatorCD.defenseModifier = statsModifier.defense
            calculatorCD.speedModifier = statsModifier.speed
            calculatorCD.healModifier = statsModifier.heal
        }
        
        return calculatorCD
    }
    
    // MARK: - Load Skills
    
    /// Load a skill from a SkillCD entity
    func loadSkill(from skillCD: SkillCD) -> Skill {
        // If using the enhanced model with effect definitions
        if let effectDefinitions = skillCD.effectDefinitions as? Set<EffectDefinitionCD>,
           !effectDefinitions.isEmpty {
            // Create effect definitions from entities
            let domainEffectDefs = effectDefinitions.map { loadEffectDefinition(from: $0) }
            
            // Create the skill with loaded effect definitions
            let skill = BaseSkill(
                name: skillCD.name ?? "Unknown Skill",
                description: skillCD.desc ?? "",
                cooldown: Int(skillCD.cooldown),
                effectDefinitions: domainEffectDefs
            )
            
            // Set current cooldown
            skill.currentCooldown = Int(skillCD.currentCooldown)
            
            return skill
        } else {
            // Using the basic model - create a simple skill
            return createDefaultSkill(from: skillCD)
        }
    }
    
    /// Load an effect definition from an EffectDefinitionCD entity
    private func loadEffectDefinition(from effectDefCD: EffectDefinitionCD) -> EffectDefinition {
        // Convert target type
        let targetType = stringToTargetType(effectDefCD.targetType ?? "singleEnemy")
        
        // Load calculators
        let calculators = loadEffectCalculators(from: effectDefCD)
        
        return EffectDefinition(targetType: targetType, effectCalculators: calculators)
    }
    
    /// Load effect calculators from an EffectDefinitionCD entity
    private func loadEffectCalculators(from effectDefCD: EffectDefinitionCD) -> [EffectCalculator] {
        guard let calculatorCDs = effectDefCD.calculators as? Set<EffectCalculatorCD> else {
            return []
        }
        
        // Convert each calculator CD to a domain calculator
        return calculatorCDs.compactMap { calculatorCD in
            switch calculatorCD.calculatorType {
            case "attack":
                let elementType = ElementType.fromString(calculatorCD.elementType ?? "neutral") ?? .neutral
                return AttackCalculator(elementType: elementType, basePower: Int(calculatorCD.basePower))
                
            case "statusEffect":
                let statusEffect = calculatorCD.statusEffect.flatMap { stringToStatusEffect($0) }
                return StatusEffectCalculator(
                    statusEffectChance: calculatorCD.statusEffectChance,
                    statusEffect: statusEffect,
                    statusEffectDuration: Int(calculatorCD.statusEffectDuration),
                    statusEffectStrength: calculatorCD.statusEffectStrength
                )
                
            case "statsModifier":
                let statsModifier = StatsModifier(
                    remainingDuration: Int(calculatorCD.statsModifierDuration),
                    attack: calculatorCD.attackModifier,
                    defense: calculatorCD.defenseModifier,
                    speed: calculatorCD.speedModifier,
                    heal: calculatorCD.healModifier
                )
                return StatsModifiersCalculator(statsModifiers: [statsModifier])
                
            default:
                return nil
            }
        }
    }
    
    /// Create a default skill when no effect definitions are available
    private func createDefaultSkill(from skillCD: SkillCD) -> Skill {
        // Create a basic default skill with neutral element
        let skill = skillFactory.createBasicSingleTargetDmgSkill(
            name: skillCD.name ?? "Unknown Skill",
            description: skillCD.desc ?? "",
            cooldown: Int(skillCD.cooldown),
            elementType: .neutral,
            basePower: 10
        )
        
        // Set current cooldown if it's a BaseSkill
        if let baseSkill = skill as? BaseSkill {
            baseSkill.currentCooldown = Int(skillCD.currentCooldown)
        }
        
        return skill
    }
    
    // MARK: - Helper Methods
    
    private func targetTypeToString(_ targetType: TargetType) -> String {
        switch targetType {
        case .singleEnemy: return "singleEnemy"
        case .all: return "all"
        case .ownself: return "ownself"
        case .allAllies: return "allAllies"
        case .allEnemies: return "allEnemies"
        case .singleAlly: return "singleAlly"
        }
    }
    
    private func stringToTargetType(_ string: String) -> TargetType {
        switch string.lowercased() {
        case "singleenemy": return .singleEnemy
        case "all": return .all
        case "ownself": return .ownself
        case "allallies": return .allAllies
        case "allenemies": return .allEnemies
        case "singleally": return .singleAlly
        default: return .singleEnemy
        }
    }
    
    private func statusEffectToString(_ statusEffect: StatusEffectType) -> String {
        switch statusEffect {
        case .stun: return "stun"
        case .poison: return "poison"
        case .burn: return "burn"
        case .frozen: return "frozen"
        case .paralysis: return "paralysis"
        case .statsModifier: return "statsModifier"
        }
    }
    
    private func stringToStatusEffect(_ string: String) -> StatusEffectType? {
        switch string.lowercased() {
        case "stun": return .stun
        case "poison": return .poison
        case "burn": return .burn
        case "frozen": return .frozen
        case "paralysis": return .paralysis
        case "statsmodifier": return .statsModifier
        default: return nil
        }
    }
}
