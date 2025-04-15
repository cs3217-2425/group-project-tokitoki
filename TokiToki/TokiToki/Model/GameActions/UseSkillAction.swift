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
    let singleTargets: [GameStateEntity]
    let playerTeam: [GameStateEntity]
    let opponentTeam: [GameStateEntity]
    let globalStatusEffectsManager: GlobalStatusEffectsManaging

    init(user: GameStateEntity, skill: Skill, _ playerTeam: [GameStateEntity],
         _ opponentTeam: [GameStateEntity], _ singleTargets: [GameStateEntity],
         _ globalStatusEffectsManager: GlobalStatusEffectsManaging) {
        self.user = user
        self.skill = skill
        self.singleTargets = singleTargets
        self.playerTeam = playerTeam
        self.opponentTeam = opponentTeam
        self.globalStatusEffectsManager = globalStatusEffectsManager
    }

    func execute() -> [EffectResult] {
        if !skill.canUse() {
            return [EffectResult(entity: user, value: 0, description: "\(skill.name) is on cooldown")]
        }

        return skill.use(from: user, playerTeam, opponentTeam, singleTargets, globalStatusEffectsManager)
    }
}
