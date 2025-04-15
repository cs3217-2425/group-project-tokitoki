//
//  EffectCalculationContext.swift
//  TokiToki
//
//  Created by proglab on 14/4/25.
//

struct EffectCalculationContext {
    let globalStatusEffectsManager: GlobalStatusEffectsManaging?
    let battleEffectsDelegate: BattleEffectsDelegate?
    let reviverDelegate: ReviverDelegate?

    init(globalStatusEffectsManager: GlobalStatusEffectsManaging? = nil,
         battleEffectsDelegate: BattleEffectsDelegate? = nil,
         reviverDelegate: ReviverDelegate? = nil) {
        self.globalStatusEffectsManager = globalStatusEffectsManager
        self.battleEffectsDelegate = battleEffectsDelegate
        self.reviverDelegate = reviverDelegate
    }
}
