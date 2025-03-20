//
//  TempTokis.swift
//  TokiToki
//
//  Created by proglab on 19/3/25.
//

let attackCalculator = AttackCalculator(elementsSystem: ElementsSystem())

let basicSpell = BaseSkill(
    name: "Basic Spell",
    description: "A basic ball of magic that deals damage to a single enemy.",
    type: .attack,
    targetType: .singleEnemy,
    elementType: .neutral,
    basePower: 20,
    cooldown: 0,
    statusEffectChance: 0,
    statusEffect: nil,
    statusEffectDuration: 0,   
    effectCalculator: attackCalculator
)

let fireball = BaseSkill(
    name: "Fireball",
    description: "A powerful ball of fire that deals damage to a single enemy and has a chance to burn.",
    type: .attack,
    targetType: .singleEnemy,
    elementType: .fire,
    basePower: 50,
    cooldown: 3,
    statusEffectChance: 0.2,   // 20% chance to apply the burn status effect.
    statusEffect: .burn,       // The fireball applies a burn status effect.
    statusEffectDuration: 2,   // The burn effect lasts for 2 turns.
    effectCalculator: attackCalculator
)

let waterGun = BaseSkill(
    name: "Water Gun",
    description: "A stream of water that deals damage to a single enemy and has a chance to reduce their speed.",
    type: .attack,
    targetType: .singleEnemy,
    elementType: .water,
    basePower: 40,   // Water Gun deals 40 points of damage (adjust as needed).
    cooldown: 2,     // Water Gun has a 2-turn cooldown.
    statusEffectChance: 0.3,   // 30% chance to reduce the target's speed.
    statusEffect: .speedDebuff,       // The water gun applies a speed debuff status effect.
    statusEffectDuration: 2,   // The speed debuff lasts for 2 turns.
    effectCalculator: attackCalculator
)

let lightningBolt = BaseSkill(
    name: "Lightning Bolt",
    description: "A bolt of lightning that deals damage to a single enemy and has a chance to paralyze them.",
    type: .attack,
    targetType: .singleEnemy,
    elementType: .air,  // Assuming Lightning as Air element (you can adjust to your game's needs).
    basePower: 60,   // Lightning Bolt deals 60 points of damage (adjust as needed).
    cooldown: 4,     // Lightning Bolt has a 4-turn cooldown.
    statusEffectChance: 0.25,   // 25% chance to apply the paralysis status effect.
    statusEffect: .paralysis,       // The lightning bolt applies a paralysis status effect.
    statusEffectDuration: 2,   // The paralysis effect lasts for 2 turns.
    effectCalculator: attackCalculator
)
