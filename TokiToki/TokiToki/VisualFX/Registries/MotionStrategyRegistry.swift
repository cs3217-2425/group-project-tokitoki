//
//  MotionStrategyRegistry.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import Foundation

class MotionStrategyRegistry {
    static let shared = MotionStrategyRegistry()

    private var strategies: [MotionParameters.MotionType: MotionCreationStrategy] = [:]

    private init() {
        registerDefaultStrategies()
    }

    func register(type: MotionParameters.MotionType, strategy: MotionCreationStrategy) {
        strategies[type] = strategy
    }

    func getStrategy(for type: MotionParameters.MotionType) -> MotionCreationStrategy {
        strategies[type] ?? DefaultMotionStrategy()
    }

    private func registerDefaultStrategies() {
        register(type: .linear, strategy: LinearMotionStrategy())
        register(type: .arc, strategy: ArcMotionStrategy())
        register(type: .bounce, strategy: BounceMotionStrategy())
        register(type: .fadeIn, strategy: FadeInMotionStrategy())
        register(type: .fadeOut, strategy: FadeOutMotionStrategy())
        register(type: .grow, strategy: GrowMotionStrategy())
        register(type: .shrink, strategy: ShrinkMotionStrategy())
        register(type: .orbit, strategy: OrbitMotionStrategy())
    }
}
