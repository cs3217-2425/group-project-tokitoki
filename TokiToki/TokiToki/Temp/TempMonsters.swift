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

func createNecroEntity(_ necro: Toki) -> GameStateEntity {
    let entity = necro.createBattleEntity()
    guard let skillsComponent = entity.getComponent(ofType: SkillsComponent.self) else {
        return entity
    }
    let rule: AIRule = UseReviveWhenAllyDeadRule(priority: 3, action: skillsComponent.skills[1])
    entity.addComponent(AIComponent(entity: entity, rules: [rule], skills: Array(skillsComponent.skills.prefix(1))))
    return entity
}

let dragon = createMonsterEntity(dragonMonsterToki)
let rhino = createMonsterEntity(rhinoMonsterToki)
let golem = createMonsterEntity(golemMonsterToki)
let necro = createNecroEntity(necroMonsterToki)

let monsterBaseStats = TokiBaseStats(hp: 100, attack: 70, defense: 10, speed: 90, heal: 0, exp: 0)
let dragonBaseStats = TokiBaseStats(hp: 200, attack: 100, defense: 10, speed: 90, heal: 0, exp: 0)
let necroBaseStats = TokiBaseStats(hp: 180, attack: 80, defense: 15, speed: 90, heal: 80, exp: 0)

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

let necroMonsterToki = Toki(
    name: "Necromancer",
    rarity: .rare,
    baseStats: necroBaseStats,
    skills: [basicSpell, soulRevive],
    equipments: [],
    elementType: [.dark],
    level: 5
)
