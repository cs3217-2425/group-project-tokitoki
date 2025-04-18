//
//  UseReviveWhenAllyDeadRule.swift
//  TokiToki
//
//  Created by proglab on 18/4/25.
//

class UseReviveWhenAllyDeadRule: AIRule {
    let priority: Int
    let skill: Skill

    init(priority: Int, action: Skill) {
        self.priority = priority
        self.skill = action
    }

    func condition(_ user: GameStateEntity, _ opponents: [GameStateEntity],
                   _ players: [GameStateEntity], _ context: EffectCalculationContext) -> UseSkillAction? {
        guard let allOpponents = context.allOponentEntities else {
            return nil
        }
        if let missingEntity = allOpponents.first(where: { opponent in
            !opponents.contains(where: { $0.id == opponent.id }) && skill.canUse()
        }) {
            return UseSkillAction(user: user, skill: skill, opponents, players, [missingEntity], context)
        }
        return nil
    }
}
