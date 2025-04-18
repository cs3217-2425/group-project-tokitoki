//
//  GlobalStatusEffectsManaging.swift
//  TokiToki
//
//  Created by proglab on 14/4/25.
//

protocol GlobalStatusEffectsManaging {
    func setDelegate(_ delegate: StatusEffectApplierAndPublisherDelegate)
    func addStatusEffect(_ statusEffect: StatusEffect, _ entity: GameStateEntity)
    func removeGlobalStatusEffectsOfDeadEntity(_ entity: GameStateEntity)
    func applyGlobalStatusEffectsAndCheckIsBattleOver(_ entities: [GameStateEntity]) -> Bool
    func updateGlobalStatusEffectsActionMeter()
    func reset()
}
