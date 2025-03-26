//
//  StatusEffectStrategyFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

// Status Effect Strategy Factory
class StatusEffectStrategyFactory {
    private var strategies: [StatusEffectType: StatusEffectStrategy] = [:]

    init() {
        registerDefaultStrategies()
    }

    private func registerDefaultStrategies() {
        strategies[.stun] = StunStrategy()
        strategies[.poison] = PoisonStrategy()
        strategies[.burn] = BurnStrategy()
        strategies[.frozen] = FrozenStrategy()
        strategies[.paralysis] = ParalysisStrategy()

        strategies[.attackBuff] = StatModifierStrategy(
            statType: "attack",
            isPositive: true,
            statModifier: { entity, strength in
                let buff = Int(Double(entity.getAttack()) * 0.2 * strength)
                StatsSystem().modifyAttack(by: buff, on: [entity])
                return buff
            }
        )

        strategies[.defenseBuff] = StatModifierStrategy(
            statType: "defense",
            isPositive: true,
            statModifier: { entity, strength in
                let buff = Int(Double(entity.getDefense()) * 0.2 * strength)
                StatsSystem().modifyDefense(by: buff, on: [entity])
                return buff
            }
        )

        strategies[.speedBuff] = StatModifierStrategy(
            statType: "speed",
            isPositive: true,
            statModifier: { entity, strength in
                let buff = Int(Double(entity.getSpeed()) * 0.2 * strength)
                StatsSystem().modifySpeed(by: buff, on: [entity])
                return buff
            }
        )

        strategies[.attackDebuff] = StatModifierStrategy(
            statType: "attack",
            isPositive: false,
            statModifier: { entity, strength in
                let debuff = -Int(Double(entity.getAttack()) * 0.2 * strength)
                StatsSystem().modifyAttack(by: debuff, on: [entity])
                return debuff
            }
        )

        strategies[.defenseDebuff] = StatModifierStrategy(
            statType: "defense",
            isPositive: false,
            statModifier: { entity, strength in
                let debuff = -Int(Double(entity.getDefense()) * 0.2 * strength)
                StatsSystem().modifyDefense(by: debuff, on: [entity])
                return debuff
            }
        )

        strategies[.speedDebuff] = StatModifierStrategy(
            statType: "speed",
            isPositive: false,
            statModifier: { entity, strength in
                let debuff = -Int(Double(entity.getSpeed()) * 0.2 * strength)
                StatsSystem().modifySpeed(by: debuff, on: [entity])
                return debuff
            }
        )
    }

    func register(strategy: StatusEffectStrategy, for type: StatusEffectType) {
        strategies[type] = strategy
    }

    func getStrategy(for type: StatusEffectType) -> StatusEffectStrategy? {
        strategies[type]
    }
}
