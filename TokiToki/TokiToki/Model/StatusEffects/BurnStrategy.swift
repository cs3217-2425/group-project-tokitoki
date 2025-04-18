//
//  BurnStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class BurnStrategy: StatusEffectStrategy {
    func apply(to entity: GameStateEntity, effect: StatusEffect) -> EffectResult {
        let damage = Int(Double(entity.getMaxHealth()) * 0.07 * effect.strength)
        entity.takeDamage(amount: damage)

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

        // TODO: Need to return both result
        // (figure out a way to make a generic StatusEffect for all cases)
        return statusResult
    }
}
