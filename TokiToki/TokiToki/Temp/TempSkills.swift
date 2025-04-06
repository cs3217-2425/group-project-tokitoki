//
//  TempTokis.swift
//  TokiToki
//
//  Created by proglab on 19/3/25.
//

let skillsFactory = SkillsFactory()

let basicSpell = BaseSkill(
    name: "Basic Spell",
    description: "A basic ball of magic that deals damage to a single enemy.",
    cooldown: 0,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .neutral, basePower: 20)
        ])
    ]
)

let fireball = BaseSkill(
    name: "Fireball",
    description: "A powerful ball of fire that deals damage to a single enemy and has a chance to burn.",
    cooldown: 3,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .fire, basePower: 50),
            StatusEffectCalculator(statusEffectChance: 1.0, statusEffect: .burn,
                                   statusEffectDuration: 2)
        ])
    ]
)

let waterGun = BaseSkill(
    name: "Water Gun",
    description: "A stream of water that deals damage to a single enemy and has a chance to reduce their speed.",
    cooldown: 2,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .water, basePower: 40),
            StatsModifiersCalculator(statsModifiers: [
                StatsModifier(remainingDuration: 2, attack: 1, defense: 1, speed: 0.5, heal: 1)
            ])
        ])
    ]
)

let lightningStorm = skillsFactory.createAoeDmgSkillWithStatusEffect(
    name: "Lightning Storm",
    description: "A storm of lightning that deals damage to all enemies and has a chance to paralyze them.",
    cooldown: 5,
    elementType: .lightning,
    basePower: 50,
    statusEffectChance: 0.15,
    statusEffect: .paralysis,
    statusEffectDuration: 2
)

let basicAttack = BaseSkill(
    name: "Basic Attack",
    description: "A basic attack that deals damage to a single enemy.",
    cooldown: 0,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .neutral, basePower: 40)
        ])
    ]
)

let excalibur = BaseSkill(
    name: "Excalibur",
    description: "A strong attack that deals damage to a single enemy.",
    cooldown: 4,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .light, basePower: 60)
        ]),
        EffectDefinition(targetType: .ownself, effectCalculators: [
            StatsModifiersCalculator(statsModifiers: [
                StatsModifier(remainingDuration: 2, attack: 1.5, defense: 1.5, speed: 1.0, heal: 1)
            ])
        ])
    ]
)

let basicArrow = BaseSkill(
    name: "Basic Arrow",
    description: "A basic arrow attack that deals damage to a single enemy.",
    cooldown: 0,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .earth, basePower: 30)
        ])
    ]
)

let iceShot = BaseSkill(
    name: "Ice Shot",
    description: "A magic arrow that deals damage to a single enemy with a chance to freeze.",
    cooldown: 3,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .ice, basePower: 40),
            StatusEffectCalculator(statusEffectChance: 0.15, statusEffect: .frozen,
                                   statusEffectDuration: 2)
        ])
    ]
)
//
// let arrowRain = BaseSkill(
//    name: "Arrow Rain",
//    description: "A shower of arrows that deals damage to all enemies.",
//    type: .attack,
//    targetType: .allEnemies,
//    elementType: .earth,
//    basePower: 40,
//    cooldown: 3,
//    effectCalculator: attackCalculator
// )

let arrowRain = BaseSkill(
    name: "Arrow Rain",
    description: "A shower of arrows that deals damage to all enemies.",
    cooldown: 3,
    effectDefinitions: [
        EffectDefinition(targetType: .allEnemies, effectCalculators: [
            AttackCalculator(elementType: .earth, basePower: 40)
        ])
    ]
)
