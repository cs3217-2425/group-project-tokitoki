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
    var equipments: [Equipment]
    var savedEquipments: [Equipment] = []
    let elementType: [ElementType]

    init(id: UUID = UUID(), name: String, rarity: ItemRarity,
         baseStats: TokiBaseStats, skills: [Skill], equipments: [Equipment],
         elementType: [ElementType], level: Int) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.baseStats = baseStats
        self.skills = skills
        self.equipments = equipments
        self.elementType = elementType
        self.level = level
        self.savedEquipments = equipments
    }

    func addTemporaryBuff(value: Int, duration: TimeInterval, stat: String) {

    }

    func gainExperience(_ exp: Int) {
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
        let entity = GameStateEntity(name, self)

        var statsComponent = StatsComponent(
            entity: entity,
            baseStats: baseStats,
            elementType: elementType
        )

        let skillsComponent = SkillsComponent(entity: entity, skills: skills)
        let statusEffectsComponent = StatusEffectsComponent(entity: entity)
        let statsModifiersComponent = StatsModifiersComponent(entity: entity)
        let equipments = equipments.filter { equipment in
            guard let equipment = equipment as? ConsumableEquipment else { return false }
            return equipment.usageContext == .battleOnlyPassive || equipment.usageContext == .battleOnly
        }
        let equipmentComponent = EquipmentComponent(inventory: equipments, entity: entity)

        // TODO: Why does equipment not have the method
//        for equipment in equipments {
//            equipment.applyBuffs(to: &statsComponent)
//        }

        entity.addComponent(statsComponent)
        entity.addComponent(skillsComponent)
        entity.addComponent(statusEffectsComponent)
        entity.addComponent(statsModifiersComponent)
        entity.addComponent(equipmentComponent)

        return entity
    }

    func levelUp(stat: TokiBaseStats) {
        self.baseStats = TokiBaseStats(
            hp: self.baseStats.hp + stat.hp,
            attack: self.baseStats.attack + stat.attack,
            defense: self.baseStats.defense + stat.defense,
            speed: self.baseStats.speed + stat.speed,
            heal: self.baseStats.heal + stat.heal,
            exp: self.baseStats.exp - levelInfo[self.level],
            critHitChance: self.baseStats.critHitChance,
            critHitDamage: self.baseStats.critHitDamage
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
    var critHitChance: Int = 15
    var critHitDamage: Int = 150
}
