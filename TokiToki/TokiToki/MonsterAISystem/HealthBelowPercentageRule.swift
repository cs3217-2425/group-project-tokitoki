//
//  HealthBelowPercentageRule.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class HealthBelowPercentageRule: AIRule {
    let priority: Int
    let action: Action
    let percentage: Double

    init(priority: Int, action: Action, percentage: Double) {
        self.priority = priority
        self.action = action
        self.percentage = percentage
    }

    func condition(_ gameState: GameState) -> Bool {
        // Check if entity's health is below the specified percentage
        if let skillAction = action as? UseSkillAction,
           let entity = gameState.getEntity(id: skillAction.sourceId),
           let statsComponent = entity.getComponent(ofType: StatsComponent.self) {
            let healthPercentage = Double(statsComponent.currentHealth) / Double(statsComponent.maxHealth) * 100
            return healthPercentage < percentage
        }
        return false
    }
}
