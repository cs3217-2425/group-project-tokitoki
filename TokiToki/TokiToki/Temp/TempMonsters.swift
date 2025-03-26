//
//  TempMonsters.swift
//  TokiToki
//
//  Created by proglab on 20/3/25.
//

let basicMonster = MonsterFactory().createBasicMonster(name: "Monster", health: 100,
                                                       attack: 50, defense: 10, speed: 90,
                                                       elementType: .air)

let basicMonster2 = MonsterFactory().createBasicMonster(name: "Monster", health: 100,
                                                       attack: 50, defense: 10, speed: 90,
                                                       elementType: .air)

let basicMonster3 = MonsterFactory().createBasicMonster(name: "Monster", health: 100,
                                                       attack: 50, defense: 10, speed: 90,
                                                       elementType: .air)

// let monsterBaseStats = TokiBaseStats(health: 100, attack: 100, defense: 10, speed: 90)
//
// let monsterToki = Toki(
//    name: "Monster",
//    rarity: .rare,
//    baseStats: monsterBaseStats,
//    skills: [basicAttack],
//    elementType: .air
// )
