//
//  StatusEffect.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

struct StatusEffect {
    let type: StatusEffectType
    var remainingDuration: Int
    let strength: Double
    let sourceId: UUID
    var actionMeter: Float = 0
    var speedOfDmgOverTime: Float = 100 // TODO: vary the speeds
    let target: GameStateEntity

    func apply(to entity: GameStateEntity, strategyFactory: StatusEffectStrategyFactory) -> EffectResult {
        guard let strategy = strategyFactory.getStrategy(for: type) else {
            return EffectResult(
                entity: entity,
                type: .none,
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
