//
//  StatusEffectVisualFXRegistry.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class StatusEffectVisualFXRegistry {
    static let shared = StatusEffectVisualFXRegistry()

    private var effectFactories: [StatusEffectType: (UIView) -> StatusEffectVisualFX] = [:]

    private init() {
        registerStatusEffectVFXs()
    }

    func register(effectType: StatusEffectType, factory: @escaping (UIView) -> StatusEffectVisualFX) {
        effectFactories[effectType] = factory
    }

    func createVisualFX(for effectType: StatusEffectType, targetView: UIView) -> StatusEffectVisualFX? {
        effectFactories[effectType]?(targetView)
    }

    private func registerStatusEffectVFXs() {
        register(effectType: .burn) { targetView in
            BurnVisualFX(targetView: targetView)
        }
        // TODO: Add other StatusEffect VisualFXs
    }
}

// Base protocol for skill visual effects
protocol StatusEffectVisualFX {
    func play(completion: @escaping () -> Void)
}
