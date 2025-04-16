//
//  TempTokis.swift
//  TokiToki
//
//  Created by proglab on 19/3/25.
//

let wizardBaseStats = TokiBaseStats(hp: 80, attack: 50, defense: 30, speed: 100, heal: 0, exp: 0)

let wizardToki = Toki(
    name: "Wizard",
    rarity: .rare,
    baseStats: wizardBaseStats,
    skills: [basicSpell, fireball, lightningStorm],
    equipments: [],
    elementType: [.fire],
    level: 0
)

let knightBaseStats = TokiBaseStats(hp: 150, attack: 40, defense: 50, speed: 95, heal: 0, exp: 0)

let knightToki = Toki(
    name: "Knight",
    rarity: .rare,
    baseStats: knightBaseStats,
    skills: [basicAttack, excalibur],
    equipments: [],
    elementType: [.light],
    level: 0
)

let archerBaseStats = TokiBaseStats(hp: 80, attack: 60, defense: 30, speed: 120, heal: 0, exp: 0)

let archerToki = Toki(
    name: "Archer",
    rarity: .rare,
    baseStats: archerBaseStats,
    skills: [basicArrow, iceShot, arrowRain],
    equipments: [revivalRing],
    elementType: [.earth],
    level: 0
)

let fireFoxBaseStats = TokiBaseStats(hp: 90, attack: 50, defense: 30, speed: 110, heal: 0, exp: 0)

let fireFoxToki = Toki(
    name: "FireFox",
    rarity: .rare,
    baseStats: fireFoxBaseStats,
    skills: [fireball, flameDance],
    equipments: [],
    elementType: [.fire],
    level: 0
)

                
