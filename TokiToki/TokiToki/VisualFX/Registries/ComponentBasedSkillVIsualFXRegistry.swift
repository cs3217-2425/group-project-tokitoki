//
//  ComponentBasedSkillVIsualFXRegistry.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

class ComponentBasedSkillVisualFXRegistry {
    static let shared = ComponentBasedSkillVisualFXRegistry()

    private var effectFactories: [SkillVisual: (UIView, UIView) -> SkillVisualFX] = [:]

    // Storage for custom combinations
    private var customEffects: [String: (ShapeParameters.ShapeType, UIColor, ParticleParameters.ParticleType)] = [:]

    private init() {
        registerSkillVisualFXs()
    }

    func register(skillVisual: SkillVisual, factory: @escaping (UIView, UIView) -> SkillVisualFX) {
        effectFactories[skillVisual] = factory
    }

    // Register a custom effect by component combination
    func registerCustomEffect(
        name: String,
        shape: ShapeParameters.ShapeType,
        color: UIColor,
        particleType: ParticleParameters.ParticleType
    ) {
        customEffects[name.lowercased()] = (shape, color, particleType)
    }

    func createVisualFX(for skillVisual: SkillVisual, sourceView: UIView, targetView: UIView) -> SkillVisualFX? {
        if let factory = effectFactories[skillVisual] {
            return factory(sourceView, targetView)
        }
        return nil
    }

    func createVisualFX(for skillName: String, sourceView: UIView, targetView: UIView) -> SkillVisualFX? {
        // Try to map to enum first
        print(skillName)
        if let skillVisual = SkillVisual.fromString(skillName) {
            return createVisualFX(for: skillVisual, sourceView: sourceView, targetView: targetView)
        }

        // Check for custom effectsa
        if let (shape, color, particleType) = customEffects[skillName.lowercased()] {
            return SkillVisualFXFactory.createVisualFX(
                sourceView: sourceView,
                targetView: targetView,
                shapeType: shape,
                color: color,
                particleType: particleType
            )
        }

        // Default fallback
        return SkillVisualFXFactory.createVisualFX(
            sourceView: sourceView,
            targetView: targetView,
            shapeType: .circle,
            color: .white,
            particleType: .circle
        )
    }

    private func registerSkillVisualFXs() {
        register(skillVisual: .fireball) { sourceView, targetView in
            SkillVisualFXFactory.createFireballFX(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .fireSlash) { sourceView, targetView in
            SkillVisualFXFactory.createFireslashFX(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .thunderBolt) { sourceView, targetView in
            SkillVisualFXFactory.createThunderboltFX(sourceView: sourceView, targetView: targetView)
        }

        registerCustomEffect(
            name: "iceslash",
            shape: .x,
            color: UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0),
            particleType: .triangle
        )
    }
}
