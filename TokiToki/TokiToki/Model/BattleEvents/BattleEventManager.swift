//
//  BattleEventManager.swift
//  TokiToki
//
//  Created by wesho on 4/4/25.
//

import Foundation

class BattleEventManager {
    static let shared = BattleEventManager()

    private let effectResultTranslator = EffectResultTranslator()

    private init() {}

    func publishEffectResult(_ result: EffectResult, sourceId: UUID) {
        let events = effectResultTranslator.translate(result, sourceId: sourceId)
        for event in events {
            EventBus.shared.post(event)
        }
    }

    func publishSkillUsedEvent(user: GameStateEntity, skill: Skill, targets: [GameStateEntity]) {
        let event = SkillUsedEvent(
            entityId: user.id,
            skillName: skill.name,
            targetIds: targets.map { $0.id }
        )
        EventBus.shared.post(event)
    }

    // Add other event publication methods as needed
}
