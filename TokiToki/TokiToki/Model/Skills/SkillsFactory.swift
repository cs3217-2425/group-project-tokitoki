//
//  SkillsFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class SkillsFactory {
    private let logger = Logger(subsystem: "SkillsFactory")
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

    func createSkill(from skillData: SkillData) -> Skill? {
        // Create an array to hold effect definitions
        var effectDefinitions: [EffectDefinition] = []

        // Process each effect definition in the skill data
        for effectDefData in skillData.effectDefinitions {
            // Determine the target type
            let targetType = convertStringToTargetType(effectDefData.targetType)

            // Array to hold effect calculators for this definition
            var effectCalculators: [EffectCalculator] = []

            // Process each calculator in the effect definition
            for calcData in effectDefData.calculators {
                switch calcData.calculatorType.lowercased() {
                case "attack":
                    // Handle attack calculator
                    if let elementTypeStr = calcData.elementType,
                       let basePower = calcData.basePower,
                       let elementType = ElementType(rawValue: elementTypeStr) {
                        effectCalculators.append(AttackCalculator(elementType: elementType, basePower: basePower))
                    }

                case "statuseffect":
                    // Handle status effect calculator
                    if let statusEffectChance = calcData.statusEffectChance,
                       let statusEffectStr = calcData.statusEffect,
                       let statusEffect = convertStringToStatusEffect(statusEffectStr),
                       let duration = calcData.statusEffectDuration,
                       let strength = calcData.statusEffectStrength {
                        effectCalculators.append(StatusEffectCalculator(
                            statusEffectChance: statusEffectChance,
                            statusEffect: statusEffect,
                            statusEffectDuration: duration,
                            statusEffectStrength: strength
                        ))
                    }

                case "statsmodifier":
                    // Handle stats modifier calculator
                    let duration = calcData.statsModifierDuration ?? 1
                    let attackMod = calcData.attackModifier ?? 1.0
                    let defenseMod = calcData.defenseModifier ?? 1.0
                    let speedMod = calcData.speedModifier ?? 1.0
                    let healMod = calcData.healModifier ?? 1.0

                    effectCalculators.append(StatsModifiersCalculator(statsModifiers: [
                        StatsModifier(
                            remainingDuration: duration,
                            attack: attackMod,
                            defense: defenseMod,
                            speed: speedMod,
                            heal: healMod
                        )
                    ]))

                case "heal":
                    // Handle heal calculator
                    let healPower = calcData.healPower ?? 10
                    effectCalculators.append(HealCalculator(healPower: healPower))

                default:
                    logger.log("Unknown calculator type: \(calcData.calculatorType)")
                }
            }

            // Add the completed effect definition if we have calculators
            if !effectCalculators.isEmpty {
                effectDefinitions.append(EffectDefinition(targetType: targetType, effectCalculators: effectCalculators))
            }
        }

        // Create and return the skill if we have at least one effect definition
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

    // Helper function to convert string to TargetType
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

    // Helper function to convert string to StatusEffectType
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
