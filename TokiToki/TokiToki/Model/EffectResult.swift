//
//  CombatSystem.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Effect Result
class EffectResult {
    let entity: Entity
    let value: Int
    let description: String

    init(entity: Entity, value: Int, description: String) {
        self.entity = entity
        self.value = value
        self.description = description
    }

    func accept(visitor: EffectResultVisitor, sourceId: UUID) -> [BattleEvent] {
        visitor.visitDefault(effectResult: self, sourceId: sourceId)
    }
}

class DamageEffectResult: EffectResult {
    let isCritical: Bool
    let elementType: ElementType

    init(entity: Entity, value: Int, description: String, isCritical: Bool, elementType: ElementType) {
        self.isCritical = isCritical
        self.elementType = elementType
        super.init(entity: entity, value: value, description: description)
    }

    override func accept(visitor: EffectResultVisitor, sourceId: UUID) -> [BattleEvent] {
        visitor.visit(damageResult: self, sourceId: sourceId)
    }
}

class StatusEffectResult: EffectResult {
    let effectType: StatusEffectType
    let duration: Int

    init(entity: Entity, effectType: StatusEffectType, duration: Int, description: String) {
        self.effectType = effectType
        self.duration = duration
        super.init(entity: entity, value: 0, description: description)
    }

    override func accept(visitor: EffectResultVisitor, sourceId: UUID) -> [BattleEvent] {
        visitor.visit(statusResult: self, sourceId: sourceId)
    }
}
