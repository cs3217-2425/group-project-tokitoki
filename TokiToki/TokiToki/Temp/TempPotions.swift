//
//  TempPotions.swift
//  TokiToki
//
//  Created by proglab on 5/4/25.
//

let healCalculator = HealCalculator(healPower: 100)

let healthPotion = Potion(name: "Health Potion",
                          description: "Restores health",
                          rarity: 1,
                          effectCalculators: [healCalculator])

let statsModifiersCalculator = StatsModifiersCalculator(statsModifiers: [
    StatsModifier(remainingDuration: 2, attack: 1.5, defense: 1.5, speed: 1.5)
])
let buffPotion = Potion(name: "Stats Buff Potion",
                        description: "Boost attack, defense and speed for 2 turns",
                        rarity: 1,
                        effectCalculators: [statsModifiersCalculator])

let critStatsModifiersCalculator = StatsModifiersCalculator(statsModifiers: [
    StatsModifier(remainingDuration: 2, criticalHitChance: 1.5, criticalHitDmg: 1.5)
])
let critPotion = Potion(name: "Crit buff Potion",
                        description: "Boost crit hit chance and crit dmg for 2 turns",
                        rarity: 1,
                        effectCalculators: [critStatsModifiersCalculator])
