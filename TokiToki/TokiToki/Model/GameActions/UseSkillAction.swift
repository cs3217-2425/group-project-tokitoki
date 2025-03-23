//
//  UseSkillAction.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Concrete Actions
class UseSkillAction: Action {
    let user: GameStateEntity
    let skill: Skill
    let targets: [GameStateEntity]

    init(user: GameStateEntity, skill: Skill, targets: [GameStateEntity]) {
        self.user = user
        self.skill = skill
        self.targets = targets
    }

    func execute() -> [EffectResult] {
        if targets.isEmpty {
            return [EffectResult(entity: user, type: .none, value: 0, description: "No valid targets")]
        }

        if !skill.canUse() {
            return [EffectResult(entity: user, type: .none, value: 0, description: "\(skill.name) is on cooldown")]
        }

        return skill.use(from: user, on: targets)
    }
}
