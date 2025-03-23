//
//  StatusEffectVisualFXComponent.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class StatusEffectVisualFXComponent: VisualFXComponent<StatusEffectAppliedEvent> {
    override func handleEvent(_ event: StatusEffectAppliedEvent) {
        let registry = StatusEffectVisualFXRegistry.shared

        guard let targetView = getView(for: event.targetId) else {
            return
        }

        if let effect = registry.createVisualFX(for: event.effectType, targetView: targetView) {
            effect.play {}
        }
    }
}
