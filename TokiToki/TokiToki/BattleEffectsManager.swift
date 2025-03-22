//
//  BattleEffectsManager.swift
//  TokiToki
//
//  Created by wesho on 22/3/25.
//

import UIKit

class BattleEffectsManager {
    private var visualComponents: [Any] = []

    init(viewController: BattleScreenViewController) {
        let viewProvider: (UUID) -> UIView? = { [weak viewController] entityId in
            viewController?.getViewForEntity(id: entityId)
        }

        setupVisualEffects(viewProvider)
    }

    private func setupVisualEffects(_ viewProvider: @escaping (UUID) -> UIView?) {
        visualComponents = [
            // Main skill effect component using registry
            SkillVisualFXComponent(viewProvider: viewProvider),

            // Element-specific components

            // Other effect components
            CriticalHitEffectComponent(viewProvider: viewProvider)
//            StatusEffectComponent(viewProvider: viewProvider)
        ]
    }

    func cleanUp() {
        visualComponents.removeAll()
    }
}
