//
//  SkillsFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

protocol SkillsFactoryProtocol {
    func getAllTemplates() -> [SkillData]
    func getTemplate(named name: String) -> SkillData?
    func createSkill(from skillData: SkillData) -> Skill?
    func createBasicSingleTargetDmgSkill(
        name: String,
        description: String,
        cooldown: Int,
        elementType: ElementType,
        basePower: Int
    ) -> Skill
    // Other skill creation methods...
}

class SkillsFactory: SkillsFactoryProtocol {
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "SkillsFactory")
    private var templates: [String: SkillData] = [:]
    
    // MARK: - Initialization
    
    init() {
        loadTemplates()
    }
    
    // MARK: - Public Methods
    
    func getAllTemplates() -> [SkillData] {
        return Array(templates.values)
    }
    
    func getTemplate(named name: String) -> SkillData? {
        return templates[name]
    }
    
    // MARK: - Skill Creation Methods
    
    func createBasicSingleTargetDmgSkill(name: String,
                                         description: String,
                                         cooldown: Int,
                                         elementType: ElementType,
                                         basePower: Int) -> Skill {
        BaseSkill(
            name: name,
            description: description,
            cooldown: cooldown,
            effectDefinitions: [
                EffectDefinition(targetType: .singleEnemy, effectCalculators: [
                    AttackCalculator(elementType: elementType, basePower: basePower)
                ])
            ]
        )
    }

    func createSingleTargetDmgSkillWithStatusEffect(name: String,
                                                    description: String,
                                                    cooldown: Int,
                                                    elementType: ElementType,
                                                    basePower: Int,
                                                    statusEffectChance: Double,
                                                    statusEffect: StatusEffectType?,
                                                    statusEffectDuration: Int = 1,
                                                    statusEffectStrength: Double = 1.0
    ) -> Skill {
        BaseSkill(
            name: name,
            description: description,
            cooldown: cooldown,
            effectDefinitions: [
                EffectDefinition(targetType: .singleEnemy, effectCalculators: [
                    AttackCalculator(elementType: elementType, basePower: basePower),
                    StatusEffectCalculator(statusEffectChance: statusEffectChance, statusEffect: statusEffect,
                                           statusEffectDuration: statusEffectDuration,
                                           statusEffectStrength: statusEffectStrength)
                ])
            ]
        )
    }

    func createAoeDmgSkillWithStatusEffect(name: String,
                                           description: String,
                                           cooldown: Int,
                                           elementType: ElementType,
                                           basePower: Int,
                                           statusEffectChance: Double,
                                           statusEffect: StatusEffectType?,
                                           statusEffectDuration: Int = 1,
                                           statusEffectStrength: Double = 1.0
    ) -> Skill {
        BaseSkill(
            name: name,
            description: description,
            cooldown: cooldown,
            effectDefinitions: [
                EffectDefinition(targetType: .allEnemies, effectCalculators: [
                    AttackCalculator(elementType: elementType, basePower: basePower),
                    StatusEffectCalculator(statusEffectChance: statusEffectChance, statusEffect: statusEffect,
                                           statusEffectDuration: statusEffectDuration,
                                           statusEffectStrength: statusEffectStrength)
                ])
            ]
        )
    }

    func createSingleTargetDmgSkillWithDebuff(name: String,
                                              description: String,
                                              cooldown: Int,
                                              elementType: ElementType,
                                              basePower: Int,
                                              duration: Int,
                                              attack: Double = 1.0,
                                              defense: Double = 1.0,
                                              speed: Double = 1.0,
                                              heal: Double = 1.0

    ) -> Skill {
        BaseSkill(
            name: name,
            description: description,
            cooldown: cooldown,
            effectDefinitions: [
                EffectDefinition(targetType: .singleEnemy, effectCalculators: [
                    AttackCalculator(elementType: elementType, basePower: basePower),
                    StatsModifiersCalculator(statsModifiers: [
                        StatsModifier(remainingDuration: duration, attack: attack, defense: defense,
                                      speed: speed, heal: heal)
                    ])
                ])
            ]
        )
    }

    func createAoeDmgSkillWithDebuff(name: String,
                                     description: String,
                                     cooldown: Int,
                                     elementType: ElementType,
                                     basePower: Int,
                                     duration: Int,
                                     attack: Double = 1.0,
                                     defense: Double = 1.0,
                                     speed: Double = 1.0,
                                     heal: Double = 1.0

    ) -> Skill {
        BaseSkill(
            name: name,
            description: description,
            cooldown: cooldown,
            effectDefinitions: [
                EffectDefinition(targetType: .allEnemies, effectCalculators: [
                    AttackCalculator(elementType: elementType, basePower: basePower),
                    StatsModifiersCalculator(statsModifiers: [
                        StatsModifier(remainingDuration: duration, attack: attack, defense: defense,
                                      speed: speed, heal: heal)
                    ])
                ])
            ]
        )
    }

    func createSingleTargetDmgSkillAndBuffSelf(name: String,
                                               description: String,
                                               cooldown: Int,
                                               elementType: ElementType,
                                               basePower: Int,
                                               duration: Int,
                                               attack: Double = 1.0,
                                               defense: Double = 1.0,
                                               speed: Double = 1.0,
                                               heal: Double = 1.0

    ) -> Skill {
        BaseSkill(
            name: name,
            description: description,
            cooldown: cooldown,
            effectDefinitions: [
                EffectDefinition(targetType: .singleEnemy, effectCalculators: [
                    AttackCalculator(elementType: elementType, basePower: basePower)
                ]),
                EffectDefinition(targetType: .ownself, effectCalculators: [
                    StatsModifiersCalculator(statsModifiers: [
                        StatsModifier(remainingDuration: duration, attack: attack, defense: defense,
                                      speed: speed, heal: heal)
                    ])
                ])

            ]
        )
    }
    
    
    /// Create a skill from a template
    func createSkill(from skillData: SkillData) -> Skill? {
        var effectDefinitions: [EffectDefinition] = []

        for effectDefData in skillData.effectDefinitions {
            let targetType = convertStringToTargetType(effectDefData.targetType)
            var effectCalculators: [EffectCalculator] = []

            for calcData in effectDefData.calculators {
                switch calcData.calculatorType.lowercased() {
                case "attack":
                    addAttackCalculator(calcData: calcData, to: &effectCalculators)
                case "statuseffect":
                    addStatusEffectCalculator(calcData: calcData, to: &effectCalculators)
                case "statsmodifier":
                    addStatsModifierCalculator(calcData: calcData, to: &effectCalculators)
                case "heal":
                    addHealCalculator(calcData: calcData, to: &effectCalculators)
                default:
                    logger.log("Unknown calculator type: \(calcData.calculatorType)")
                }
            }

            if !effectCalculators.isEmpty {
                effectDefinitions.append(EffectDefinition(targetType: targetType, effectCalculators: effectCalculators))
            }
        }

        if !effectDefinitions.isEmpty {
            return BaseSkill(
                name: skillData.name,
                description: skillData.description,
                cooldown: skillData.cooldown,
                effectDefinitions: effectDefinitions
            )
        }

        return nil
    }
    
    // MARK: - Private Helper Methods
    
    private func loadTemplates() {
        do {
            let skillsData: SkillsData = try ResourceLoader.loadJSON(fromFile: "Skills")
            for skill in skillsData.skills {
                templates[skill.name] = skill
            }
            logger.log("Loaded \(templates.count) skill templates")
        } catch {
            logger.logError("Failed to load skill templates: \(error)")
        }
    }
    
    private func addAttackCalculator(calcData: CalculatorData, to calculators: inout [EffectCalculator]) {
        if let elementTypeStr = calcData.elementType,
           let basePower = calcData.basePower,
           let elementType = ElementType(rawValue: elementTypeStr) {
            calculators.append(AttackCalculator(elementType: elementType, basePower: basePower))
        }
    }
    
    private func addStatusEffectCalculator(calcData: CalculatorData, to calculators: inout [EffectCalculator]) {
        if let statusEffectChance = calcData.statusEffectChance,
           let statusEffectStr = calcData.statusEffect,
           let statusEffect = convertStringToStatusEffect(statusEffectStr),
           let duration = calcData.statusEffectDuration,
           let strength = calcData.statusEffectStrength {
            calculators.append(StatusEffectCalculator(
                statusEffectChance: statusEffectChance,
                statusEffect: statusEffect,
                statusEffectDuration: duration,
                statusEffectStrength: strength
            ))
        }
    }
    
    private func addStatsModifierCalculator(calcData: CalculatorData, to calculators: inout [EffectCalculator]) {
        let duration = calcData.statsModifierDuration ?? 1
        let attackMod = calcData.attackModifier ?? 1.0
        let defenseMod = calcData.defenseModifier ?? 1.0
        let speedMod = calcData.speedModifier ?? 1.0
        let healMod = calcData.healModifier ?? 1.0
        let critChanceMod = calcData.critChanceModifier ?? 1.0
        let critDmgModifier = calcData.critDmgModifier ?? 1.0

        calculators.append(StatsModifiersCalculator(statsModifiers: [
            StatsModifier(
                remainingDuration: duration,
                attack: attackMod,
                defense: defenseMod,
                speed: speedMod,
                heal: healMod,
                criticalHitChance: critChanceMod,
                criticalHitDmg: critDmgModifier
            )
        ]))
    }
    
    private func addHealCalculator(calcData: CalculatorData, to calculators: inout [EffectCalculator]) {
        let healPower = calcData.healPower ?? 10
        calculators.append(HealCalculator(healPower: healPower))
    }
    
    // MARK: - Type Conversion Helpers
    
    private func convertStringToTargetType(_ string: String) -> TargetType {
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

    private func convertStringToStatusEffect(_ string: String) -> StatusEffectType? {
        switch string.lowercased() {
        case "stun": return .stun
        case "poison": return .poison
        case "burn": return .burn
        case "frozen": return .frozen
        case "paralysis": return .paralysis
        default: return nil
        }
    }
}
