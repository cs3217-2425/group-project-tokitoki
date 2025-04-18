//
//  HealthBelowPercentageRule.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

// Opponent will use a certain skill when hp drop below a certain percentage
class HealthBelowPercentageRule: AIRule {
    let priority: Int
    let skill: Skill
    let percentage: Double
    let statsSystem = StatsSystem()

    init(priority: Int, action: Skill, percentage: Double) {
        self.priority = priority
        self.skill = action
        self.percentage = percentage
    }

    func condition(_ user: GameStateEntity, _ opponents: [GameStateEntity], _ players: [GameStateEntity],
                   _ context: EffectCalculationContext) -> UseSkillAction? {
        // Check if entity's health is below the specified percentage
        let healthPercentage = Double(statsSystem.getCurrentHealth(user))
        / Double(statsSystem.getMaxHealth(user)) * 100
        if healthPercentage < percentage && skill.canUse() {
            return UseSkillAction(user: user, skill: skill, opponents, players, [user], context)
        }
        return nil
    }
}
