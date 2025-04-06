//
//  EffectResultVisitor.swift
//  TokiToki
//
//  Created by wesho on 4/4/25.
//

import Foundation

protocol EffectResultVisitor {
    func visit(damageResult: DamageEffectResult, sourceId: UUID) -> [BattleEvent]
    func visit(statusResult: StatusEffectResult, sourceId: UUID) -> [BattleEvent]
    // Add more visit methods for other effect result types

    func visitDefault(effectResult: EffectResult, sourceId: UUID) -> [BattleEvent]
}
