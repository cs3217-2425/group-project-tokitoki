//
//  TempMonsters.swift
//  TokiToki
//
//  Created by proglab on 20/3/25.
//

func createMonsterEntity(_ monster: Toki) -> GameStateEntity {
    let entity = monster.createBattleEntity()
    entity.addComponent(AIComponent(entity: entity, rules: [], skills: monster.skills))
    return entity
}

let monsterBaseStats = TokiBaseStats(hp: 100, attack: 70, defense: 10, speed: 90, heal: 0, exp: 0)
let dragonBaseStats = TokiBaseStats(hp: 200, attack: 100, defense: 10, speed: 90, heal: 0, exp: 0)

let dragonMonsterToki = Toki(
    name: "Dragon",
    rarity: .rare,
    baseStats: dragonBaseStats,
    skills: [basicAttack, fireball],
    equipments: [],
    elementType: [.fire],
    level: 5
)

let rhinoMonsterToki = Toki(
    name: "Rhino",
    rarity: .rare,
    baseStats: monsterBaseStats,
    skills: [basicAttack],
    equipments: [],
    elementType: [.water],
    level: 1
)

let golemMonsterToki = Toki(
    name: "Golem",
    rarity: .rare,
    baseStats: monsterBaseStats,
    skills: [basicAttack],
    equipments: [],
    elementType: [.earth],
    level: 1
)
