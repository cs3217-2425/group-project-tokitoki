//
//  GameEventFactory.swift
//  TokiToki
//
//  Created by wesho on 22/3/25.
//

import Foundation

class GameEventFactory {
    func createSkillUsedEvent(user: GameStateEntity, skill: Skill, targets: [GameStateEntity]) -> BattleEvent {
        SkillUsedEvent(
            entityId: user.id,
            skillName: skill.name,
            elementType: skill.elementType,
            targetIds: targets.map { $0.id }
        )
    }

    func createDamageEvent(source: GameStateEntity, target: GameStateEntity, amount: Int,
                          isCritical: Bool, elementType: ElementType) -> BattleEvent {
        DamageDealtEvent(
            sourceId: source.id,
            targetId: target.id,
            amount: amount,
            isCritical: isCritical,
            elementType: elementType
        )
    }

    // TODO: Other factory methods for other events
}
