//
//  AIComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// AI Component for opponents to determine which skill to use
class AIComponent: Component {
    var rules: [AIRule]
    var skills: [Skill]
    let entity: Entity

    init(entity: Entity, rules: [AIRule], skills: [Skill]) {
        self.rules = rules
        self.skills = skills
        self.entity = entity
    }

    func determineAction(_ userEntity: GameStateEntity, _ playerEntities: [GameStateEntity],
                         _ opponentEntities: [GameStateEntity],
                         _ context: EffectCalculationContext) -> Action {
        var actionToUse: Action?
        rules.sort { $0.priority > $1.priority }
        for rule in rules  {
            actionToUse = rule.condition(userEntity, opponentEntities, playerEntities, context)
            if actionToUse == nil {
                continue
            } else {
                break
            }
        }

        guard let actionToUse = actionToUse else {
            let skillToUse = skills.filter { $0.canUse() }.randomElement()
            guard let skillToUse = skillToUse else {
                return NoAction(entity: userEntity)
            }
            return UseSkillAction(user: userEntity, skill: skillToUse, opponentEntities,
                                         playerEntities, [], context)
        }

        return actionToUse
    }
}
