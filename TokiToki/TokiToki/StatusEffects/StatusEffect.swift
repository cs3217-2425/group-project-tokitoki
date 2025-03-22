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
    func apply(to entity: GameStateEntity, strategyFactory: StatusEffectStrategyFactory) -> EffectResult {
        if let strategy = strategyFactory.getStrategy(for: type) {
            return strategy.apply(to: entity, effect: self)
        }

        // Default fallback
        return StatusEffectResult(
            entity: entity,
            effectType: type,
            duration: remainingDuration,
            description: "No effect applied (no strategy found)"
        )
    }
}
