//
//  AIComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// AI Component for monsters
class AIComponent: BaseComponent {
    var rules: [AIRule]

    init(entityId: UUID, rules: [AIRule]) {
        self.rules = rules
        super.init(entityId: entityId)
    }

    func determineAction(gameState: GameState) -> Action {
        for rule in rules {
            if rule.condition(gameState) {
                return rule.action
            }
        }

        // Default action if no rules match
        return rules.first?.action ?? NoAction()
    }
}
