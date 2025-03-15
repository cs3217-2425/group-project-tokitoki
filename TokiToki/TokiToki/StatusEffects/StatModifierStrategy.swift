//
//  StatModifierStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class StatModifierStrategy: StatusEffectStrategy {
    let statType: String
    let isPositive: Bool
    let statModifier: (Entity, Double) -> Int

    init(statType: String, isPositive: Bool, statModifier: @escaping (Entity, Double) -> Int) {
        self.statType = statType
        self.isPositive = isPositive
        self.statModifier = statModifier
    }

    func apply(to entity: Entity, effect: StatusEffect) -> EffectResult {
        let value = statModifier(entity, effect.strength)
        let direction = isPositive ? "increased" : "decreased"
        let absValue = abs(value)

        return EffectResult(
            entity: entity,
            type: isPositive ? .buff : .debuff,
            value: value,
            description: "\(entity.getName())'s \(statType) \(direction) by \(absValue)!"
        )
    }
}
