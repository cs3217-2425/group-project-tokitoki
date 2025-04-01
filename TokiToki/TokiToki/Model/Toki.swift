//
//  Toki.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation
// MARK: - Toki Class for Gacha and Display

class Toki: IGachaItem {
    let id: UUID
    let name: String
    var level: Int
    let rarity: ItemRarity
    var baseStats: TokiBaseStats
    var skills: [any Skill]
    var equipment: [Equipment]
    let elementType: ElementType
    
    var ownerId: UUID? = nil
    var dateAcquired: Date? = nil

    init(id: UUID = UUID(), name: String, rarity: ItemRarity,
         baseStats: TokiBaseStats, skills: [Skill], equipments: [Equipment],
         elementType: ElementType, level: Int, ownerId: UUID? = nil, dateAcquired: Date? = nil) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.baseStats = baseStats
        self.skills = skills
        self.equipment = equipments
        self.elementType = elementType
        self.level = level
        self.ownerId = ownerId
        self.dateAcquired = dateAcquired
    }

    func createBattleEntity() -> GameStateEntity {
        let entity = GameStateEntity(name)

        // Add components
        var statsComponent = StatsComponent(
            entityId: entity.id,
            maxHealth: baseStats.hp,
            attack: baseStats.attack,
            defense: baseStats.defense,
            speed: baseStats.speed,
            elementType: elementType
        )

        let skillsComponent = SkillsComponent(entityId: entity.id, skills: skills)
        let statusEffectsComponent = StatusEffectsComponent(entityId: entity.id)
        
        for e in equipment {
            e.applyBuffs(to: &statsComponent)
        }

        entity.addComponent(statsComponent)
        entity.addComponent(skillsComponent)
        entity.addComponent(statusEffectsComponent)

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
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
    let heal: Int
    let exp: Int
}

enum TokiRarity: String {
    case common = "common"
    case rare = "rare"
    case legendary = "legendary"
}
