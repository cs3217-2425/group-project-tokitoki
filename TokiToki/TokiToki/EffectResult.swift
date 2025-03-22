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
enum EffectResultType {
    case damage
    case heal
    case defense
    case buff
    case debuff
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
