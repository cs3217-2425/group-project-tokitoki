//
//  UseSkillAction.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Concrete Actions
class UseSkillAction: Action {
    let sourceId: UUID
    let skillId: UUID
    let targetIds: [UUID]

    init(sourceId: UUID, skillId: UUID, targetIds: [UUID]) {
        self.sourceId = sourceId
        self.skillId = skillId
        self.targetIds = targetIds
    }

    func execute(gameState: GameState) -> [EffectResult] {
        guard let source = gameState.getEntity(id: sourceId),
              let skillsComponent = source.getComponent(ofType: SkillsComponent.self) else {
            return [EffectResult(entity: BaseEntity(), type: .none, value: 0, description: "Invalid source or skill")]
        }

        guard let skill = skillsComponent.skills.first(where: { $0.id == skillId }) else {
            return [EffectResult(entity: source, type: .none, value: 0, description: "Skill not found")]
        }

        let targets = targetIds.compactMap { gameState.getEntity(id: $0) }

        if targets.isEmpty {
            return [EffectResult(entity: source, type: .none, value: 0, description: "No valid targets")]
        }

        if !skill.canUse() {
            return [EffectResult(entity: source, type: .none, value: 0, description: "\(skill.name) is on cooldown")]
        }

        return skill.use(from: source, on: targets)
    }
}
