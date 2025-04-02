//
//  Skill.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

protocol Skill {
    var name: String { get }
    var description: String { get }
    var cooldown: Int { get }
    var currentCooldown: Int { get set }
    var effectDefinitions: [EffectDefinition] { get }
    func canUse() -> Bool
    func use(from source: GameStateEntity, _ playerTeam: [GameStateEntity],
             _ opponentTeam: [GameStateEntity], _ singleTargets: [GameStateEntity]) -> [EffectResult]
    func startCooldown()
    func reduceCooldown()
    func resetCooldown()
}

enum SkillType {
    case attack
    case heal
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
    case statsModifier
}
