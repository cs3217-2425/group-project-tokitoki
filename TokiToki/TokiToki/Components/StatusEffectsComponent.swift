//
//  StatusEffectsComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class StatusEffectsComponent: BaseComponent {
    var activeEffects: [StatusEffect]

    override init(entityId: UUID) {
        self.activeEffects = []
        super.init(entityId: entityId)
    }

    func addEffect(_ effect: StatusEffect) {
        activeEffects.append(effect)
    }

    func removeEffect(id: UUID) {
        activeEffects.removeAll { $0.id == id }
    }

    func updateEffects() {
        activeEffects = activeEffects.map { effect in
            var updatedEffect = effect
            updatedEffect.remainingDuration -= 1
            return updatedEffect
        }.filter { $0.remainingDuration > 0 }
    }

    func hasEffect(ofType type: StatusEffectType) -> Bool {
        activeEffects.contains { $0.type == type }
    }
}
