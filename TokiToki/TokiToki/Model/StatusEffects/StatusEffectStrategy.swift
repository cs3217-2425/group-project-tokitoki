//
//  StatusEffectStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

// MARK: - Status Effect System (Using Strategy Pattern instead of Switch)

protocol StatusEffectStrategy {
    func apply(to entity: GameStateEntity, effect: StatusEffect) -> EffectResult
}
