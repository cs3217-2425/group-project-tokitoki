//
//  TempMonsters.swift
//  TokiToki
//
//  Created by proglab on 20/3/25.
//

let mappingOfTokiToCreationFunction: [String: (Toki) -> GameStateEntity] = [
    "Necromancer": createNecroEntity,
    "Totem": createTotemEntity
]

func createMonsterEntity(_ monster: Toki) -> GameStateEntity {
    let entity = monster.createBattleEntity()
    guard let skillsComponent = entity.getComponent(ofType: SkillsComponent.self) else {
        return entity
    }
    entity.addComponent(AIComponent(entity: entity, rules: [], skills: skillsComponent.skills))
    return entity
}

func createNecroEntity(_ necro: Toki) -> GameStateEntity {
    let entity = necro.createBattleEntity()
    guard let skillsComponent = entity.getComponent(ofType: SkillsComponent.self) else {
        return entity
    }
    let rule: AIRule = UseReviveWhenAllyDeadRule(priority: 3, action: skillsComponent.skills[2])
    entity.addComponent(AIComponent(entity: entity, rules: [rule], skills: Array(skillsComponent.skills.prefix(2))))
    return entity
}

func createTotemEntity(_ totem: Toki) -> GameStateEntity {
    let entity = totem.createBattleEntity()
    guard let skillsComponent = entity.getComponent(ofType: SkillsComponent.self) else {
        return entity
    }
    let rule: AIRule = TeamHealthBelowPercentageRule(priority: 3, action: skillsComponent.skills[0], percentage: 50)
    entity.addComponent(AIComponent(entity: entity, rules: [rule], skills: [skillsComponent.skills[1]]))
    return entity
}

let dragon = createMonsterEntity(dragonMonsterToki)
let rhino = createMonsterEntity(rhinoMonsterToki)
let golem = createMonsterEntity(golemMonsterToki)
let necro = createNecroEntity(necroMonsterToki)

let monsterBaseStats = TokiBaseStats(hp: 100, attack: 70, defense: 10, speed: 90, heal: 0, exp: 0)
let dragonBaseStats = TokiBaseStats(hp: 200, attack: 100, defense: 10, speed: 90, heal: 0, exp: 0)
let necroBaseStats = TokiBaseStats(hp: 180, attack: 80, defense: 15, speed: 90, heal: 30, exp: 0)
let electricFoxBaseStats = TokiBaseStats(hp: 150, attack: 70, defense: 10, speed: 150, heal: 30, exp: 0)

let dragonMonsterToki = Toki(
    name: "Dragon",
    rarity: .rare,
    baseStats: dragonBaseStats,
    skills: [basicAttack, fireball, meteorShower],
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
    skills: [lifeLeech, acidSpray, soulRevive],
    equipments: [],
    elementType: [.dark],
    level: 5
)

let totemMonsterToki = Toki(
    name: "Totem",
    rarity: .rare,
    baseStats: monsterBaseStats,
    skills: [basicAttack, singleHeal, aoeBuff],
    equipments: [],
    elementType: [.air],
    level: 1
)

let electricFoxMonsterToki = Toki(
    name: "Lightning Fox",
    rarity: .rare,
    baseStats: electricFoxBaseStats,
    skills: [basicAttack, flash, thunderClap],
    equipments: [],
    elementType: [.lightning],
    level: 5
)
