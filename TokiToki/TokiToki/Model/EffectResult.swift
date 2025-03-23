//
//  CombatSystem.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Effect Result Enum
enum EffectResultType {
    case damage
    case heal
    case defense
    case buff
    case debuff
    case statusApplied
    case statusRemoved
    case none
}

// Effect Result
struct EffectResult {
    let entity: Entity
    let type: EffectResultType
    let value: Int
    let description: String
}
