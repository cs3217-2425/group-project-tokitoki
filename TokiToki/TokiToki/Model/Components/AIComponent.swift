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
                         _ globalStatusEffectsManager: GlobalStatusEffectsManaging) -> Action {
//        guard let skillsComponent = userEntity.getComponent(ofType: SkillsComponent.self) else {
//            return NoAction(entity: userEntity)
//        }
        var skillToUse: Skill?
        for rule in rules where rule.condition(userEntity) {
            skillToUse = rule.skill
        }

        if skillToUse == nil {
            skillToUse = skills.filter { $0.canUse() }.randomElement()
        }

        guard let skillToUse = skillToUse else {
            return NoAction(entity: userEntity)
        }

        return UseSkillAction(user: userEntity, skill: skillToUse, opponentEntities,
                              playerEntities, [], globalStatusEffectsManager)
    }
}
