//
//  SkillVisualFXComponent.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class SkillVisualFXComponent: VisualFXComponent<SkillUsedEvent> {
    override func handleEvent(_ event: SkillUsedEvent) {
        guard let sourceView = getView(for: event.entityId) else {
            return
        }

//        let registry = SkillVisualFXRegistry.shared
        let registry = ComponentBasedSkillVisualFXRegistry.shared

        for targetId in event.targetIds {
            guard let targetView = getView(for: targetId) else {
                continue
            }

            // Try to get skill-specific effect
            if let effect = registry.createVisualFX(for: event.skillName,
                                                    sourceView: sourceView, targetView: targetView) {
                effect.play {}
            }
        }
    }
}
