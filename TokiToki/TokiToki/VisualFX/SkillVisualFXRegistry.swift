//
//  SkillVisualFXRegistry.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class SkillVisualFXRegistry {
    static let shared = SkillVisualFXRegistry()

    private var effectFactories: [String: (UIView, UIView) -> SkillVisualFX] = [:]

    private init() {
        registerSkillVisualFXs()
    }

    func register(skillName: String, factory: @escaping (UIView, UIView) -> SkillVisualFX) {
        effectFactories[skillName] = factory
    }

    func createEffect(for skillName: String, sourceView: UIView, targetView: UIView) -> SkillVisualFX? {
        effectFactories[skillName.lowercased()]?(sourceView, targetView)
    }

    private func registerSkillVisualFXs() {
        // TODO: Standardize skillName to be used for the skills (Need better decoupling)
        register(skillName: "fireball") { sourceView, targetView in
            FireballEffect(sourceView: sourceView, targetView: targetView)
        }

        register(skillName: "fireslash") { sourceView, targetView in
            FireslashEffect(sourceView: sourceView, targetView: targetView)
        }

        // TODO: Other skill SkillVisualFX
    }
}

// Base protocol for skill visual effects
protocol SkillVisualFX {
    func play(completion: @escaping () -> Void)
}
