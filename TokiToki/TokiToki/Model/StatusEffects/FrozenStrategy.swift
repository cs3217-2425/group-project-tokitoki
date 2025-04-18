//
//  FrozenStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class FrozenStrategy: StatusEffectStrategy {
    func apply(to entity: GameStateEntity, effect: StatusEffect) -> [EffectResult] {
        let statusResult = StatusEffectResult(
            entity: entity,
            effectType: effect.type,
            duration: effect.remainingDuration,
            description: "\(entity.getName()) is frozen and cannot move!"
        )
        return [statusResult]
    }
}
