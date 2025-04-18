//
//  BattleEvent.swift
//  TokiToki
//
//  Created by wesho on 22/3/25.
//

import Foundation

protocol BattleEvent: GameEvent {
}

struct DamageDealtEvent: BattleEvent {
    let sourceId: UUID
    let targetId: UUID
    let amount: Int
    let isCritical: Bool
    let elementType: ElementType
}

struct SkillUsedEvent: BattleEvent {
    let entityId: UUID
    let skillName: String
    let targetIds: [UUID]
}
struct HealingEvent: BattleEvent {
    let sourceId: UUID
    let targetId: UUID
    let amount: Int
}

struct StatusEffectAppliedEvent: BattleEvent {
    let targetId: UUID
    let effectType: StatusEffectType
    let duration: Int
}

struct StatusEffectRemovedEvent: BattleEvent {
    let targetId: UUID
    let effectType: StatusEffectType
}

struct EntityDefeatedEvent: BattleEvent {
    let entityId: UUID
    let entityName: String
}

struct BattleEndedEvent: BattleEvent {
    let isWin: Bool
}
