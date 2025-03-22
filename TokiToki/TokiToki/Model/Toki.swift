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
    let level: Int
    let rarity: TokiRarity
    let baseStats: TokiBaseStats
    let skills: [Skill]
    let equipment: [Equipment]
    let elementType: ElementType

    init(id: UUID = UUID(), name: String, rarity: TokiRarity, baseStats: TokiBaseStats, skills: [Skill], equipments: [Equipment], elementType: ElementType, level: Int) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.baseStats = baseStats
        self.skills = skills
        self.equipment = equipments
        self.elementType = elementType
        self.level = level
    }

    func createBattleEntity() -> PlayerEntity {
        let entity = PlayerEntity(name: name)

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
}

struct TokiBaseStats {
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
    let heal: Int
    let exp: Int
}

enum TokiRarity {
    case common
    case uncommon
    case rare
    case epic
    case legendary
}
