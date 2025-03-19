//
//  TempTokis.swift
//  TokiToki
//
//  Created by proglab on 19/3/25.
//

let wizardBaseStats = TokiBaseStats(health: 80, attack: 50, defense: 30, speed: 40)

let wizardToki = Toki(
    name: "Wizard",
    rarity: .rare,
    baseStats: wizardBaseStats,
    skills: [fireball, waterGun, lightningBolt],
    elementType: .fire  
)
