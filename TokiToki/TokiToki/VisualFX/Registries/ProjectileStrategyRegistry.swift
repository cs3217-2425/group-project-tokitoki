//
//  ProjectileStrategyRegistry.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import Foundation

// Registry for projectile strategies
class ProjectileStrategyRegistry {
    static let shared = ProjectileStrategyRegistry()

    private var strategies: [ProjectileType: ProjectileStrategy] = [:]

    private init() {
        registerDefaultStrategies()
    }

    func register(type: ProjectileType, strategy: ProjectileStrategy) {
        strategies[type] = strategy
    }

    func getStrategy(for type: ProjectileType) -> ProjectileStrategy {
        strategies[type] ?? LinearProjectileStrategy()  // Default to linear if type not found
    }

    private func registerDefaultStrategies() {
        register(type: .linear, strategy: LinearProjectileStrategy())
        register(type: .arc, strategy: ArcProjectileStrategy())
    }
}
