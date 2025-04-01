//
//  CombatSystem.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

protocol BattleEventConvertible {
    func toBattleEvents(sourceId: UUID) -> [BattleEvent]
}

// Effect Result Enum
// why does effect result need type again?
enum EffectResultType {
    case damage
    case heal
    case defense
    case statsModified
    case statusApplied
    case statusRemoved
    case none
}

// Effect Result
class EffectResult: BattleEventConvertible {
    let entity: Entity
    let type: EffectResultType
    let value: Int
    let description: String

    init(entity: Entity, type: EffectResultType, value: Int, description: String) {
        self.entity = entity
        self.type = type
        self.value = value
        self.description = description
    }

    func toBattleEvents(sourceId: UUID) -> [BattleEvent] {
        []
    }
}

class DamageEffectResult: EffectResult {
    let isCritical: Bool
    let elementType: ElementType

    init(entity: Entity, value: Int, description: String, isCritical: Bool, elementType: ElementType) {
        self.isCritical = isCritical
        self.elementType = elementType
        super.init(entity: entity, type: .damage, value: value, description: description)
    }

    override func toBattleEvents(sourceId: UUID) -> [BattleEvent] {
        [DamageDealtEvent(
            sourceId: sourceId,
            targetId: entity.id,
            amount: value,
            isCritical: isCritical,
            elementType: elementType
        )]
    }
}

class StatusEffectResult: EffectResult {
    let effectType: StatusEffectType
    let duration: Int

    init(entity: Entity, effectType: StatusEffectType, duration: Int, description: String) {
        self.effectType = effectType
        self.duration = duration
        super.init(entity: entity, type: .statusApplied, value: 0, description: description)
    }

    override func toBattleEvents(sourceId: UUID) -> [BattleEvent] {
        [StatusEffectAppliedEvent(
            targetId: entity.id,
            effectType: effectType,
            duration: duration
        )]
    }
}
