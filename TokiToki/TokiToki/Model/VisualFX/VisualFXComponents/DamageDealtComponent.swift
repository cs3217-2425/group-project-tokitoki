//
//  DamageDealtComponent.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class DamageDealtComponent: VisualFXComponent<DamageDealtEvent> {
    override func handleEvent(_ event: DamageDealtEvent) {
        guard let targetView = getView(for: event.targetId) else {
            return
        }

        let effect = DamageDealtVisualFX(targetView: targetView)

        effect.play(amount: event.amount, isCritical: event.isCritical) {}
    }
}
