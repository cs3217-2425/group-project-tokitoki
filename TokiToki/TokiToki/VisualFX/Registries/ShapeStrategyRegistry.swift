//
//  ShapeStrategyRegistry.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import Foundation

class ShapeStrategyRegistry {
    static let shared = ShapeStrategyRegistry()

    // Dictionary mapping shape types to their respective creation strategies
    private var strategies: [ShapeParameters.ShapeType: ShapeCreationStrategy] = [:]

    private init() {
        registerDefaultStrategies()
    }

    // Register a strategy for a specific shape type
    func register(type: ShapeParameters.ShapeType, strategy: ShapeCreationStrategy) {
        strategies[type] = strategy
    }

    // Get the appropriate strategy for a shape type, with fallback to a default
    func getStrategy(for type: ShapeParameters.ShapeType) -> ShapeCreationStrategy {
        strategies[type] ?? DefaultShapeStrategy()
    }

    // Register built-in strategies during initialization
    private func registerDefaultStrategies() {
        register(type: .circle, strategy: CircleShapeStrategy())
        register(type: .square, strategy: SquareShapeStrategy())
        register(type: .triangle, strategy: TriangleShapeStrategy())
        register(type: .x, strategy: XShapeStrategy())
        register(type: .line, strategy: LineShapeStrategy())
        register(type: .arc, strategy: ArcShapeStrategy())
        register(type: .spiral, strategy: SpiralShapeStrategy())
        register(type: .star, strategy: StarShapeStrategy())
    }
}
