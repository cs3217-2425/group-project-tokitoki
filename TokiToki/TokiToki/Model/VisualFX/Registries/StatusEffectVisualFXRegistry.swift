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
        register(effectType: .frozen) { targetView in
            FrozenVisualFX(targetView: targetView)
        }
        register(effectType: .stun) { targetView in
            StunVisualFX(targetView: targetView)
        }
        register(effectType: .paralysis) { targetView in
            ParalysisVisualFX(targetView: targetView)
        }
        register(effectType: .poison) { targetView in
            PoisonVisualFX(targetView: targetView)
        }
    }
}

// Base protocol for skill visual effects
protocol StatusEffectVisualFX {
    func play(completion: @escaping () -> Void)
}
