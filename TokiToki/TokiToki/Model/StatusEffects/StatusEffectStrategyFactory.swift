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
    }

    func register(strategy: StatusEffectStrategy, for type: StatusEffectType) {
        strategies[type] = strategy
    }

    func getStrategy(for type: StatusEffectType) -> StatusEffectStrategy? {
        strategies[type]
    }
}
