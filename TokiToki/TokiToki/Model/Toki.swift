//
//  Toki.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation
// MARK: - Toki Class for Gacha and Display

class Toki {
    let id: UUID
    let name: String
    var level: Int
    let rarity: TokiRarity
    var baseStats: TokiBaseStats
    var skills: [Skill]
    var equipments: [Equipment]
    let elementType: ElementType

    init(id: UUID = UUID(), name: String, rarity: TokiRarity,
         baseStats: TokiBaseStats, skills: [Skill], equipments: [Equipment],
         elementType: ElementType, level: Int) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.baseStats = baseStats
        self.skills = skills
        self.equipments = equipments
        self.elementType = elementType
        self.level = level
    }

    func createBattleEntity() -> GameStateEntity {
        let entity = GameStateEntity(name)

        // Add components
        var statsComponent = StatsComponent(
            entity: entity,
            baseStats: baseStats,
            elementType: elementType
        )

        let skillsComponent = SkillsComponent(entity: entity, skills: skills)
        let statusEffectsComponent = StatusEffectsComponent(entity: entity)
        let statsModifiersComponent = StatsModifiersComponent(entity: entity)

        for equipment in equipments {
            equipment.applyBuffs(to: &statsComponent)
        }

        entity.addComponent(statsComponent)
        entity.addComponent(skillsComponent)
        entity.addComponent(statusEffectsComponent)
        entity.addComponent(statsModifiersComponent)

        return entity
    }

    func levelUp(stat: TokiBaseStats) {
        self.baseStats = TokiBaseStats(
            hp: self.baseStats.hp + stat.hp,
            attack: self.baseStats.attack + stat.attack,
            defense: self.baseStats.defense + stat.defense,
            speed: self.baseStats.speed + stat.speed,
            heal: self.baseStats.heal + stat.heal,
            exp: self.baseStats.exp - 100
            )
        self.level += 1
    }
}

struct TokiBaseStats {
    var hp: Int
    var attack: Int
    var defense: Int
    var speed: Int
    var heal: Int
    var exp: Int
}

enum TokiRarity: String {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
}
