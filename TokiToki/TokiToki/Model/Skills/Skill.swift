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
    func use(from source: Entity, on targets: [Entity]) -> [EffectResult]
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
    case single
    case all
    case ownself
    case allAllies
    case allEnemies
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
