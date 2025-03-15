//
//  FrozenStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class FrozenStrategy: StatusEffectStrategy {
    func apply(to entity: Entity, effect: StatusEffect) -> EffectResult {
        EffectResult(
            entity: entity,
            type: .statusApplied,
            value: 0,
            description: "\(entity.getName()) is frozen and cannot move!"
        )
    }
}
