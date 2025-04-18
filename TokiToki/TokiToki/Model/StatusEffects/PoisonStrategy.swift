//
//  PoisonStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class PoisonStrategy: StatusEffectStrategy {
    private let statsSystem = StatsSystem()

    func apply(to entity: GameStateEntity, effect: StatusEffect) -> [EffectResult] {
        let damage = Int(Double(statsSystem.getMaxHealth(entity)) * 0.05 * effect.strength)
        statsSystem.inflictDamage(amount: damage, [entity])

        var damageResult = DamageEffectResult(
            entity: entity,
            value: damage,
            description: "\(entity.getName()) takes \(damage) poison damage!",
            isCritical: false,
            elementType: .neutral
        )

        let statusResult = StatusEffectResult(
            entity: entity,
            effectType: effect.type,
            duration: effect.remainingDuration,
            description: "\(entity.getName()) is poisoned!"
        )

        return [damageResult, statusResult]
    }
}
