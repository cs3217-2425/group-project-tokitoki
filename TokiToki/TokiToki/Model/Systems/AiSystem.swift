//
//  AiSystem.swift
//  TokiToki
//
//  Created by proglab on 20/4/25.
//

class AiSystem: System {
    func update(_ entities: [GameStateEntity]) {

    }

    func reset(_ entities: [GameStateEntity]) {

    }

    func determineAction(_ userEntity: GameStateEntity, _ playerEntities: [GameStateEntity],
                         _ opponentEntities: [GameStateEntity],
                         _ context: EffectCalculationContext) -> Action {
        guard let aiComponent = userEntity.getComponent(ofType: AIComponent.self) else {
            return NoAction(entity: userEntity)
        }
        var rules = aiComponent.rules
        let skills = aiComponent.skills
        var actionToUse: Action?
        rules.sort { $0.priority > $1.priority }
        for rule in rules {
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
