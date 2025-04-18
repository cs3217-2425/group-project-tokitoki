//
//  AIComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// AI Component for opponents to determine which skill to use
class AIComponent: BaseComponent {
    var rules: [AIRule]
    var skills: [Skill]

    init(entityId: UUID, rules: [AIRule], skills: [Skill]) {
        self.rules = rules
        self.skills = skills
        super.init(entityId: entityId)
    }

    func determineAction(_ userEntity: GameStateEntity, _ playerEntities: [GameStateEntity],
                         _ opponentEntities: [GameStateEntity]) -> Action {
        var skillToUse: Skill?
        for rule in rules where rule.condition(userEntity) {
            skillToUse = rule.skill
        }

        if skillToUse == nil {
            skillToUse = skills.filter { $0.canUse() }.randomElement()
        }

        guard let skillToUse = skillToUse else {
            return NoAction()
        }

        let targets = TargetSelectionFactory().generateTargets(opponentEntities, playerEntities, skillToUse.targetType)
        return UseSkillAction(user: userEntity, skill: skillToUse, targets: targets) // todo: targets
    }
}
