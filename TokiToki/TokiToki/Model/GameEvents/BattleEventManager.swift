//
//  BattleEventManager.swift
//  TokiToki
//
//  Created by wesho on 4/4/25.
//

import Foundation

class BattleEventManager {
    private let effectResultTranslator = EffectResultTranslator()

    init() {}

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

    func publishBattleEndedEvents(isWin: Bool, exp: Int, gold: Int) {
        let event = BattleEndedEvent(isWin: isWin, exp: exp, gold: gold)
        EventBus.shared.post(event)
    }
}
