//
//  ParticleStrategyRegistry.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import Foundation

class ParticleStrategyRegistry {
    static let shared = ParticleStrategyRegistry()

    private var strategies: [ParticleType: ParticleCreationStrategy] = [:]

    private init() {
        registerDefaultStrategies()
    }

    func register(type: ParticleType, strategy: ParticleCreationStrategy) {
        strategies[type] = strategy
    }

    func getStrategy(for type: ParticleType) -> ParticleCreationStrategy {
        strategies[type] ?? DefaultParticleStrategy()
    }

    private func registerDefaultStrategies() {
        register(type: .circle, strategy: CircleParticleStrategy())
        register(type: .square, strategy: SquareParticleStrategy())
        register(type: .triangle, strategy: TriangleParticleStrategy())
        register(type: .spark, strategy: SparkParticleStrategy())
        register(type: .smoke, strategy: SmokeParticleStrategy())
        register(type: .bubble, strategy: BubbleParticleStrategy())
        register(type: .star, strategy: StarParticleStrategy())
    }
}
