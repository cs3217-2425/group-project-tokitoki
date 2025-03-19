//
//  HealthBelowPercentageRule.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

// Opponent will use a certain skill when hp drop below a certain percentage
class HealthBelowPercentageRule: AIRule {
    let priority: Int
    let skillAction: UseSkillAction
    let percentage: Double

    init(priority: Int, action: UseSkillAction, percentage: Double) {
        self.priority = priority
        self.skillAction = action
        self.percentage = percentage
    }

    func condition(_ entity: GameStateEntity) -> Bool {
        // Check if entity's health is below the specified percentage
        if let statsComponent = entity.getComponent(ofType: StatsComponent.self) {
            let healthPercentage = Double(statsComponent.currentHealth) / Double(statsComponent.maxHealth) * 100
            return healthPercentage < percentage
        }
        return false
    }
}
