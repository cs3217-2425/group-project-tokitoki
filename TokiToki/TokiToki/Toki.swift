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
    let rarity: TokiRarity
    let baseStats: TokiBaseStats
    let skills: [Skill]
    let elementType: ElementType

    init(id: UUID = UUID(), name: String, rarity: TokiRarity, baseStats: TokiBaseStats, skills: [Skill], elementType: ElementType) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.baseStats = baseStats
        self.skills = skills
        self.elementType = elementType
    }

    func createBattleEntity() -> TokiGameStateEntity {
        let entity = TokiGameStateEntity(name: name)

        // Add components
        let statsComponent = StatsComponent(
            entityId: entity.id,
            maxHealth: baseStats.health,
            attack: baseStats.attack,
            defense: baseStats.defense,
            speed: baseStats.speed,
            elementType: elementType
        )

        let skillsComponent = SkillsComponent(entityId: entity.id, skills: skills)
        let statusEffectsComponent = StatusEffectsComponent(entityId: entity.id)

        entity.addComponent(statsComponent)
        entity.addComponent(skillsComponent)
        entity.addComponent(statusEffectsComponent)

        return entity
    }
}

struct TokiBaseStats {
    let health: Int
    let attack: Int
    let defense: Int
    let speed: Int
}

enum TokiRarity {
    case common
    case uncommon
    case rare
    case epic
    case legendary
}
