//
//  BurnStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class BurnStrategy: StatusEffectStrategy {
    private let statsSystem = StatsSystem()

    func apply(to entity: GameStateEntity, effect: StatusEffect) -> [EffectResult] {
        let damage = Int(Double(statsSystem.getMaxHealth(entity)) * 0.07 * effect.strength)
        statsSystem.inflictDamage(amount: damage, [entity])

        // Return the damage effect result
        var damageResult = DamageEffectResult(
            entity: entity,
            value: damage,
            description: "\(entity.getName()) takes \(damage) burn damage!",
            isCritical: false,
            elementType: .fire
        )

        // Return the status effect result
        let statusResult = StatusEffectResult(
            entity: entity,
            effectType: effect.type,
            duration: effect.remainingDuration,
            description: "\(entity.getName()) is burning!"
        )

        return [damageResult, statusResult]
    }
}
