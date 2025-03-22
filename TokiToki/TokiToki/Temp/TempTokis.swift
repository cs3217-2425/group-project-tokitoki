//
//  TempTokis.swift
//  TokiToki
//
//  Created by proglab on 19/3/25.
//

let wizardBaseStats = TokiBaseStats(health: 80, attack: 50, defense: 30, speed: 100)

let wizardToki = Toki(
    name: "Wizard",
    rarity: .rare,
    baseStats: wizardBaseStats,
    skills: [basicSpell, fireball],
    elementType: .fire
)

let knightBaseStats = TokiBaseStats(health: 150, attack: 40, defense: 50, speed: 95)

let knightToki = Toki(
    name: "Knight",
    rarity: .rare,
    baseStats: knightBaseStats,
    skills: [basicAttack, excalibur],
    elementType: .light
)
