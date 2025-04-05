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
    let rarity: ItemRarity
    var baseStats: TokiBaseStats
    var skills: [Skill]
    var equipment: [Equipment]
    let elementType: ElementType

    init(id: UUID = UUID(), name: String, rarity: ItemRarity,
         baseStats: TokiBaseStats, skills: [Skill], equipments: [Equipment],
         elementType: ElementType, level: Int) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.baseStats = baseStats
        self.skills = skills
        self.equipment = equipments
        self.elementType = elementType
        self.level = level
    }
    
    func addTemporaryBuff(value: Int, duration: TimeInterval, stat: String) {
        print("Toki receives a temporary buff: \(stat) +\(value) for \(duration) sec")
        // In a full implementation, integrate with a buff manager.
    }
    
    func gainExperience(_ exp: Int) {
        print("Toki gains \(exp) EXP")
        // Update experience
        self.baseStats = TokiBaseStats(
            hp: self.baseStats.hp,
            attack: self.baseStats.attack,
            defense: self.baseStats.defense,
            speed: self.baseStats.speed,
            heal: self.baseStats.heal,
            exp: self.baseStats.exp + exp
        )
    }

    func createBattleEntity() -> GameStateEntity {
        let entity = GameStateEntity(name)

        // Add components
        let statsComponent = StatsComponent(
            entityId: entity.id,
            maxHealth: baseStats.hp,
            attack: baseStats.attack,
            defense: baseStats.defense,
            speed: baseStats.speed,
            elementType: elementType
        )

        let skillsComponent = SkillsComponent(entityId: entity.id, skills: skills)
        let statusEffectsComponent = StatusEffectsComponent(entityId: entity.id)
        
//        for e in equipment {
//            e.applyBuffs(to: &statsComponent)
//        }

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

