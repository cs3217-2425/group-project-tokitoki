//
//  PoisonStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class PoisonStrategy: StatusEffectStrategy {
    func apply(to entity: Entity, effect: StatusEffect) -> EffectResult {
        let damage = Int(Double(entity.getMaxHealth()) * 0.05 * effect.strength)
        entity.takeDamage(amount: damage)
        return EffectResult(
            entity: entity,
            type: .damage,
            value: damage,
            description: "\(entity.getName()) takes \(damage) poison damage!"
        )
    }
}
