//
//  Skill.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

protocol Skill {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var type: SkillType { get }
    var targetType: TargetType { get }
    var elementType: ElementType { get }
    var basePower: Int { get }
    var cooldown: Int { get }
    var currentCooldown: Int { get set }
    var statusEffectChance: Double { get }
    var statusEffect: StatusEffectType? { get }
    var statusEffectDuration: Int { get }

    func canUse() -> Bool
    func use(from source: GameStateEntity, on targets: [GameStateEntity]) -> [EffectResult]
    func startCooldown()
    func reduceCooldown()
}

enum SkillType {
    case attack
    case heal
    case defend
    case buff
    case debuff
}

enum TargetType {
    case singleEnemy
    case all
    case ownself
    case allAllies
    case allEnemies
    case singleAlly
}

enum StatusEffectType {
    case stun
    case poison
    case burn
    case frozen
    case paralysis
    case attackBuff
    case defenseBuff
    case speedBuff
    case attackDebuff
    case defenseDebuff
    case speedDebuff
}

enum SkillVisual: String, CaseIterable {
    case fireball = "fireball"
    case fireSlash = "fireslash"
    case iceSpear = "icespear"
    case thunderBolt = "thunderbolt"
    case heal = "heal"
    case shield = "shield"

    // Fallback for string-based lookup when needed
    static func fromString(_ string: String) -> SkillVisual? {
        SkillVisual(rawValue: string.lowercased())
    }
}
