//
//  ParticleStrategyRegistry.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import Foundation

class ParticleStrategyRegistry {
    static let shared = ParticleStrategyRegistry()
    
    private var strategies: [ParticleParameters.ParticleType: ParticleCreationStrategy] = [:]

    private init() {
        registerDefaultStrategies()
    }
    
    func register(type: ParticleParameters.ParticleType, strategy: ParticleCreationStrategy) {
        strategies[type] = strategy
    }
    
    func getStrategy(for type: ParticleParameters.ParticleType) -> ParticleCreationStrategy {
        return strategies[type] ?? DefaultParticleStrategy()
    }
    
    private func registerDefaultStrategies() {
        register(type: .circle, strategy: CircleParticleStrategy())
        register(type: .square, strategy: SquareParticleStrategy())
        register(type: .triangle, strategy: TriangleParticleStrategy())
        register(type: .spark, strategy: SparkParticleStrategy())
        register(type: .smoke, strategy: SmokeParticleStrategy())
        register(type: .bubble, strategy: BubbleParticleStrategy())
    }
}
