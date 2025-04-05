//
//  ParalysisStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class ParalysisStrategy: StatusEffectStrategy {
    func apply(to entity: GameStateEntity, effect: StatusEffect) -> EffectResult {
        if Double.random(in: 0...1) < 0.5 {
            return EffectResult(
                entity: entity,
                value: 0,
                description: "\(entity.getName()) is paralyzed and can't move!"
            )
        }
        return EffectResult(
            entity: entity,
            value: 0,
            description: "\(entity.getName()) overcomes paralysis!"
        )
    }
}
