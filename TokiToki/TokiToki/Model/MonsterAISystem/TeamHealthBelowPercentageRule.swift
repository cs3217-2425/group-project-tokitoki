//
//  TeamHealthBelowPercentageRule.swift
//  TokiToki
//
//  Created by proglab on 19/4/25.
//

class TeamHealthBelowPercentageRule: AIRule {
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
        for opponent in opponents {
            let healthPercentage = Double(statsSystem.getCurrentHealth(opponent))
            / Double(statsSystem.getMaxHealth(opponent)) * 100
            if healthPercentage < percentage && skill.canUse() {
                return UseSkillAction(user: user, skill: skill, opponents, players, [opponent], context)
            }
        }
        return nil
    }
}
