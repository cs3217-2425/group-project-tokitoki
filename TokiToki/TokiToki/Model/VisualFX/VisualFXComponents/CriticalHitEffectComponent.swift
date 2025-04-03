//
//  CriticalHitEffectComponent.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class CriticalHitEffectComponent: VisualFXComponent<DamageDealtEvent> {
    override func handleEvent(_ event: DamageDealtEvent) {
        guard event.isCritical else {
            return
        }

        guard let targetView = getView(for: event.targetId) else {
            return
        }

        let effect = CriticalHitVisualFX(targetView: targetView)

        effect.play(amount: event.amount) {}
    }
}
