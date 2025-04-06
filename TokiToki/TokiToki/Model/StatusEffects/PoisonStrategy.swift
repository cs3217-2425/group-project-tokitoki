//
//  PoisonStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class PoisonStrategy: StatusEffectStrategy {
    private let statsSystem = StatsSystem()

    func apply(to entity: GameStateEntity, effect: StatusEffect) -> EffectResult {
        let damage = Int(Double(statsSystem.getMaxHealth(entity)) * 0.05 * effect.strength)
        statsSystem.inflictDamage(amount: damage, [entity])

        return EffectResult(
            entity: entity,
            value: damage,
            description: "\(entity.getName()) takes \(damage) poison damage!"
        )
    }
}
