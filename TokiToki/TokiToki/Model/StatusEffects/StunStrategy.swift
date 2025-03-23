//
//  StunStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class StunStrategy: StatusEffectStrategy {
    func apply(to entity: GameStateEntity, effect: StatusEffect) -> EffectResult {
        EffectResult(
            entity: entity,
            type: .statusApplied,
            value: 0,
            description: "\(entity.getName()) is stunned and unable to act!"
        )
    }
}
