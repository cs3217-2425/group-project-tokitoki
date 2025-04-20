//
//  GlobalStatusEffectsManager.swift
//  TokiToki
//
//  Created by proglab on 14/4/25.
//

class GlobalStatusEffectsManager: GlobalStatusEffectsManaging {
    private var globalStatusEffects: [StatusEffect] = []
    private let statusEffectsSystem: StatusEffectsSystem
    private let allGlobalStatusEffects: Set<StatusEffectType> = [.burn, .poison]
    private let MAX_ACTION_BAR: Float
    private let MULTIPLIER_FOR_ACTION_METER: Float
    private var statusEffectApplierAndPublisherDelegate: StatusEffectApplierAndPublisherDelegate?

    init(_ statusEffectsSystem: StatusEffectsSystem, _ max_action_bar: Float, _ multiplier_for_action_meter: Float) {
        self.statusEffectsSystem = statusEffectsSystem
        self.MAX_ACTION_BAR = max_action_bar
        self.MULTIPLIER_FOR_ACTION_METER = multiplier_for_action_meter
    }

    func setDelegate(_ delegate: StatusEffectApplierAndPublisherDelegate) {
        self.statusEffectApplierAndPublisherDelegate = delegate
    }

    func addStatusEffect(_ statusEffect: StatusEffect, _ entity: GameStateEntity) {
        if checkIfStatusEffectIsGlobal(statusEffect) {
            addGlobalStatusEffect(statusEffect, entity)
        } else {
            statusEffectsSystem.addEffect(statusEffect, entity, renewExistingEffectElseAddEffect(_:_:_:))
        }
    }

    private func addGlobalStatusEffect(_ statusEffect: StatusEffect, _ entity: GameStateEntity) {
        renewExistingEffectElseAddEffect(statusEffect, entity, &globalStatusEffects)
    }

    func renewExistingEffectElseAddEffect(_ statusEffect: StatusEffect, _ entity: GameStateEntity,
                                                  _ statusEffects: inout [StatusEffect]) {
        guard let index = statusEffects.firstIndex(where: {
            $0.type == statusEffect.type && $0.targetId == entity.id
        }) else {
            statusEffects.append(statusEffect)
            return
        }
        var sameEffect = statusEffects[index]
        sameEffect.remainingDuration = statusEffect.remainingDuration // renew the duration
        statusEffects[index] = sameEffect
    }

    func removeGlobalStatusEffectsOfDeadEntity(_ entity: GameStateEntity) {
        globalStatusEffects.removeAll { $0.targetId == entity.id }
    }

    private func checkIfStatusEffectIsGlobal(_ effect: StatusEffect) -> Bool {
        allGlobalStatusEffects.contains(effect.type)
    }

    func updateGlobalStatusEffectsActionMeter() {
        for i in globalStatusEffects.indices {
            globalStatusEffects[i].updateActionMeter(by: MULTIPLIER_FOR_ACTION_METER)
        }
    }

    func applyGlobalStatusEffectsAndCheckIsBattleOver(_ entities: [GameStateEntity]) -> Bool {
        var isBattleOver = false
        for globalStatusEffect in globalStatusEffects
            where globalStatusEffect.actionMeter >= MAX_ACTION_BAR {
            let target = entities.first { $0.id == globalStatusEffect.targetId }
            guard let target = target,
                  let statusEffectApplierAndPublisherDelegate = statusEffectApplierAndPublisherDelegate else {
                return false
            }
            isBattleOver = statusEffectApplierAndPublisherDelegate
                .applyStatusEffectAndPublishResult(globalStatusEffect, target)
            updateGlobalStatusEffect(globalStatusEffect)
        }
        return isBattleOver
    }

    private func updateGlobalStatusEffect(_ statusEffect: StatusEffect) {
        var updatedEffect = statusEffect
        updatedEffect.remainingDuration -= 1
        updatedEffect.actionMeter -= MAX_ACTION_BAR

        globalStatusEffects = globalStatusEffects
            .map { $0.type == updatedEffect.type ? updatedEffect : $0 }
            .filter { $0.remainingDuration > 0 }
    }

    func reset() {
        globalStatusEffects = []
    }
}
