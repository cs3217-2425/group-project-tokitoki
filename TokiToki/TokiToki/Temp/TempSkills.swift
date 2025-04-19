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
            AttackCalculator(elementType: .neutral, basePower: 40)
        ])
    ]
).clone()

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
).clone()

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
).clone()

let lightningStorm = skillsFactory.createAoeDmgSkillWithStatusEffect(
    name: "Lightning Storm",
    description: "A storm of lightning that deals damage to all enemies and has a chance to paralyze them.",
    cooldown: 5,
    elementType: .lightning,
    basePower: 50,
    statusEffectChance: 0.15,
    statusEffect: .paralysis,
    statusEffectDuration: 2
).clone()

let basicAttack = BaseSkill(
    name: "Basic Attack",
    description: "A basic attack that deals damage to a single enemy.",
    cooldown: 0,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .neutral, basePower: 40)
        ])
    ]
).clone()

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
).clone()

let basicArrow = BaseSkill(
    name: "Basic Arrow",
    description: "A basic arrow attack that deals damage to a single enemy.",
    cooldown: 0,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .earth, basePower: 30)
        ])
    ]
).clone()

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
).clone()

let arrowRain = BaseSkill(
    name: "Arrow Rain",
    description: "A shower of arrows that deals damage to all enemies.",
    cooldown: 3,
    effectDefinitions: [
        EffectDefinition(targetType: .allEnemies, effectCalculators: [
            AttackCalculator(elementType: .earth, basePower: 40)
        ])
    ]
).clone()

let flameDance = BaseSkill(
    name: "Flame Dance",
    description: "A dance of fire",
    cooldown: 3,
    effectDefinitions: [
        EffectDefinition(targetType: .allEnemies, effectCalculators: [
            AttackCalculator(elementType: .fire, basePower: 40)
        ])
    ]
).clone()

let soulRevive = BaseSkill(
    name: "Soul Revive",
    description: "Revives a fallen ally. Debuffs all enemies",
    cooldown: 5,
    effectDefinitions: [
        EffectDefinition(targetType: .singleAlly, effectCalculators: [
            ReviveCalculator(revivePower: 0.8)
        ]),
        EffectDefinition(targetType: .allEnemies, effectCalculators: [
            StatsModifiersCalculator(statsModifiers: [
                StatsModifier(remainingDuration: 2, attack: 0.5, defense: 0.5, speed: 0.5, heal: 0.5)
            ])
        ])
    ]
).clone()

let acidSpray = BaseSkill(
    name: "Acid Spray",
    description: "A spray of acid that deals damage to all enemies.",
    cooldown: 3,
    effectDefinitions: [
        EffectDefinition(targetType: .allEnemies, effectCalculators: [
            AttackCalculator(elementType: .dark, basePower: 40),
            StatusEffectCalculator(statusEffectChance: 0.75, statusEffect: .poison,
                                   statusEffectDuration: 2, statusEffectStrength: 2)
        ])
    ]
).clone()

let aoeBuff = BaseSkill(
    name: "AOE Buff",
    description: "Buff all allies",
    cooldown: 3,
    effectDefinitions: [
        EffectDefinition(targetType: .allAllies, effectCalculators: [
            StatsModifiersCalculator(statsModifiers: [
                StatsModifier(remainingDuration: 2, attack: 1.5, defense: 1.5, speed: 1.0, heal: 1.5)
            ])
        ])
    ]
).clone()

let singleHeal = BaseSkill(
    name: "Single Heal",
    description: "Heals one ally",
    cooldown: 2,
    effectDefinitions: [
        EffectDefinition(targetType: .singleAlly, effectCalculators: [
            HealCalculator(healPower: 50)
        ])
    ]
).clone()

let meteorShower = BaseSkill(
    name: "Meteor Shower",
    description: "A barrage of meteorites that deal damage to all enemies and chance to burn.",
    cooldown: 4,
    effectDefinitions: [
        EffectDefinition(targetType: .allEnemies, effectCalculators: [
            AttackCalculator(elementType: .fire, basePower: 50),
            StatusEffectCalculator(statusEffectChance: 0.5, statusEffect: .burn,
                                   statusEffectDuration: 2, statusEffectStrength: 1)
        ])
    ]
).clone()

let lifeLeech = BaseSkill(
    name: "Life Leech",
    description: "Steals a portion of the damage dealt to enemies.",
    cooldown: 0,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .dark, basePower: 20),
        ]),
        EffectDefinition(targetType: .ownself, effectCalculators: [
            HealCalculator(healPower: 0),
        ])
    ]
).clone()

let flash = BaseSkill(
    name: "Flash",
    description: "Deals damage to single enemy and buff speed.",
    cooldown: 3,
    effectDefinitions: [
        EffectDefinition(targetType: .ownself, effectCalculators: [
            StatsModifiersCalculator(statsModifiers: [
                StatsModifier(remainingDuration: 1, attack: 1.0, defense: 1.0, speed: 1.5, heal: 1)
            ])
        ]),
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .lightning, basePower: 50)
        ])
    ]
).clone()

let thunderClap = BaseSkill(
    name: "Thunder Clap",
    description: "Deals single enemy and chance to paralyse",
    cooldown: 5,
    effectDefinitions: [
        EffectDefinition(targetType: .singleEnemy, effectCalculators: [
            AttackCalculator(elementType: .lightning, basePower: 70),
            StatusEffectCalculator(statusEffectChance: 0.5, statusEffect: .paralysis,
                                   statusEffectDuration: 2, statusEffectStrength: 1)
    ])
]).clone()

        
