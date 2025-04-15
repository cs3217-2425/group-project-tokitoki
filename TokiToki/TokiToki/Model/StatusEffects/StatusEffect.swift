//
//  StatusEffect.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

struct StatusEffect: Codable {
    let type: StatusEffectType
    var remainingDuration: Int
    let strength: Double
    let sourceId: UUID
    var actionMeter: Float = 0
    var speedOfDmgOverTime: Float {
        type.defaultSpeedOfDmgOverTime
    }
    let targetId: UUID

    func apply(to entity: GameStateEntity, strategyFactory: StatusEffectStrategyFactory) -> EffectResult {
        guard let strategy = strategyFactory.getStrategy(for: type) else {
            return EffectResult(
                entity: entity,
                value: 0,
                description: "No effect applied (no strategy found)"
            )
        }
        return strategy.apply(to: entity, effect: self)
    }

    mutating func updateActionMeter(by multiplier: Float) {
        self.actionMeter += speedOfDmgOverTime * multiplier
    }
}

extension StatusEffect: Equatable {
    static func == (lhs: StatusEffect, rhs: StatusEffect) -> Bool {
        lhs.type == rhs.type &&
        lhs.remainingDuration == rhs.remainingDuration && lhs.strength == rhs.strength
        && lhs.sourceId == rhs.sourceId && lhs.targetId == rhs.targetId
    }
}
