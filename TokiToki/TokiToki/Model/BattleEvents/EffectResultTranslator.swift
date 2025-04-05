//
//  EffectResultTranslator.swift
//  TokiToki
//
//  Created by wesho on 4/4/25.
//

import Foundation

class EffectResultTranslator: EffectResultVisitor {
    func visit(damageResult: DamageEffectResult, sourceId: UUID) -> [BattleEvent] {
        [DamageDealtEvent(
            sourceId: sourceId,
            targetId: damageResult.entity.id,
            amount: damageResult.value,
            isCritical: damageResult.isCritical,
            elementType: damageResult.elementType
        )]
    }

    func visit(statusResult: StatusEffectResult, sourceId: UUID) -> [BattleEvent] {
        [StatusEffectAppliedEvent(
            targetId: statusResult.entity.id,
            effectType: statusResult.effectType,
            duration: statusResult.duration
        )]
    }

    // Default implementation for any unhandled types
    func visitDefault(effectResult: EffectResult, sourceId: UUID) -> [BattleEvent] {
        print("Warning: No specific handler for EffectResult type: \(type(of: effectResult))")
        return []
    }

    // Main translate method that clients will call
    func translate(_ effectResult: EffectResult, sourceId: UUID) -> [BattleEvent] {
        effectResult.accept(visitor: self, sourceId: sourceId)
    }
}
