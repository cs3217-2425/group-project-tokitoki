//
//  StatusEffect.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// StatusEffect uses Strategy Pattern
struct StatusEffect {
    let id = UUID()
    let type: StatusEffectType
    var remainingDuration: Int
    let strength: Double
    let sourceId: UUID

    // Function to apply effect using strategy pattern
    func apply(to entity: Entity, strategyFactory: StatusEffectStrategyFactory) -> EffectResult {
        if let strategy = strategyFactory.getStrategy(for: type) {
            return strategy.apply(to: entity, effect: self)
        }

        return EffectResult(
            entity: entity,
            type: .none,
            value: 0,
            description: "No effect applied (no strategy found)"
        )
    }
}
