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
    let allOponentEntities: [GameStateEntity]?

    init(globalStatusEffectsManager: GlobalStatusEffectsManaging? = nil,
         battleEffectsDelegate: BattleEffectsDelegate? = nil,
         reviverDelegate: ReviverDelegate? = nil,
         allOpponentEntities: [GameStateEntity]? = nil) {
        self.globalStatusEffectsManager = globalStatusEffectsManager
        self.battleEffectsDelegate = battleEffectsDelegate
        self.reviverDelegate = reviverDelegate
        self.allOponentEntities = allOpponentEntities
    }
}
