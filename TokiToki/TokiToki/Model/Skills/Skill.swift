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
             _ opponentTeam: [GameStateEntity], _ singleTargets: [GameStateEntity],
             _ context: EffectCalculationContext) -> [EffectResult]
    func startCooldown()
    func reduceCooldown()
    func resetCooldown()
    func clone() -> Skill
}

enum SkillType {
    case revive
}

enum TargetType {
    case singleEnemy
    case all
    case ownself
    case allAllies
    case allEnemies
    case singleAlly
}

enum StatusEffectType: String, CaseIterable, Codable {
    case stun
    case poison
    case burn
    case frozen
    case paralysis
    case statsModifier

    var defaultSpeedOfDmgOverTime: Float {
        switch self {
        case .burn:
            return 120
        case .poison:
            return 80
        default:
            return 100
        }
    }
}

enum SkillVisual: String, CaseIterable {
    case fireball = "fireball"
    case fireSlash = "fireslash"
    case excalibur = "excalibur"
    case iceShot = "ice shot"
    case arrowRain = "arrow rain"
    case lightningStorm = "lightning storm"
    case earthquake = "earthquake"
    case earthShield = "earth shield"
    case flameDance = "flame dance"
    case healingWave = "healing wave"
    case acidSpray = "acid spray"
    case singleHeal = "single heal"
    case waterBlast = "water blast"
    case finalJudgement = "final judgement"
    
    // Fallback for string-based lookup when needed
    static func fromString(_ string: String) -> SkillVisual? {
        SkillVisual(rawValue: string.lowercased())
    }
}
