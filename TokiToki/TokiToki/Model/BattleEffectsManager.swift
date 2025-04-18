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

        setupVisualEffects(viewProvider, viewController)
    }

    private func setupVisualEffects(_ viewProvider: @escaping (UUID) -> UIView?,
                                    _ viewController: BattleScreenViewController) {
        visualComponents = [
            // Main skill effect component using registry
            SkillVisualFXComponent(viewProvider: viewProvider),

            // Status effect component
            StatusEffectVisualFXComponent(viewProvider: viewProvider),

            // Other effect components
            DamageDealtComponent(viewProvider: viewProvider),

            // Battle ended components
            BattleEndComponent(viewProvider: viewProvider, viewController: viewController)
        ]
    }

    func cleanUp() {
        visualComponents.removeAll()
    }
}
