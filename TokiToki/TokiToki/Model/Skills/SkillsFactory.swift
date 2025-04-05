//
//  SkillsFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class SkillsFactory {
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
                    AttackCalculator(elementType: elementType, basePower: basePower),
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
}
