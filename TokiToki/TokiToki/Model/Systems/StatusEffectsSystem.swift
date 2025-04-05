//
//  StatusEffectsSystem.swift
//  TokiToki
//
//  Created by proglab on 26/3/25.
//

import Foundation

class StatusEffectsSystem: System {
    static let shared = StatusEffectsSystem()
    let statsSystem = StatsSystem()
    var priority = 1
    private let strategyFactory = StatusEffectStrategyFactory()
    private let allDmgOverTimeStatusEffects: [StatusEffectType] = [.burn, .poison]
    var currentDmgOverTimeStatusEffects: [StatusEffect] = []
    private let multiplierForActionMeter: Float = GameEngine.multiplierForActionMeter
    private let MAX_ACTION_BAR: Float = GameEngine.MAX_ACTION_BAR
    private var gameEngine: GameEngine?
    
    private init() {}
    
    func setGameEngine(_ gameEngine: GameEngine) {
        self.gameEngine = gameEngine
    }
    
    fileprivate func applyStatusEffectAndPublishResult(_ effect: StatusEffect,
                                                       _ entity: GameStateEntity,
                                                       _ logMessage: (String) -> Void,
                                                       _ battleEffectsDelegate: BattleEffectsDelegate?
    ) {
        let result = effect.apply(to: entity, strategyFactory: strategyFactory)
        logMessage(result.description)
        battleEffectsDelegate?.updateHealthBar(entity.id, statsSystem.getCurrentHealth(entity),
                                               statsSystem.getMaxHealth(entity)) { [weak self] in
            self?.gameEngine?.checkIfEntitiesAreDead()
        }
        
        for event in result.toBattleEvents(sourceId: effect.sourceId) {
            EventBus.shared.post(event)
        }
    }
    
    func update(_ entities: [GameStateEntity], _ logMessage: (String) -> Void) {
        for entity in entities {
            guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
                return
            }

            for effect in statusComponent.activeEffects {
                applyStatusEffectAndPublishResult(effect, entity, logMessage, nil)
            }

            updateEffects(statusComponent)
        }
    }

    func update(_ entities: [GameStateEntity]) {

    }
    
    func updateDmgOverTimeEffectsActionMeter() {
        for i in currentDmgOverTimeStatusEffects.indices {
            currentDmgOverTimeStatusEffects[i].updateActionMeter(by: multiplierForActionMeter)
        }
    }
    
    func applyDmgOverTimeStatusEffects(_ logMessage: (String) -> Void,
                                       _ battleEffectsDelegate: BattleEffectsDelegate?)  {
        for currentDmgOverTimeStatusEffect in currentDmgOverTimeStatusEffects
            where currentDmgOverTimeStatusEffect.actionMeter >= MAX_ACTION_BAR {
            applyStatusEffectAndPublishResult(currentDmgOverTimeStatusEffect,
                                              currentDmgOverTimeStatusEffect.target, logMessage, battleEffectsDelegate)
            updateDmgOverTimeStatusEffect(currentDmgOverTimeStatusEffect)
        }
        
    }
    
    private func updateDmgOverTimeStatusEffect(_ statusEffect: StatusEffect) {
        var updatedEffect = statusEffect  
        updatedEffect.remainingDuration -= 1
        updatedEffect.actionMeter -= MAX_ACTION_BAR

        currentDmgOverTimeStatusEffects = currentDmgOverTimeStatusEffects
            .map { $0.type == updatedEffect.type ? updatedEffect : $0 }
            .filter { $0.remainingDuration > 0 }
    }

    private func updateEffects(_ statusComponent: StatusEffectsComponent) {
        statusComponent.activeEffects = statusComponent.activeEffects.map { effect in
            var updatedEffect = effect
            updatedEffect.remainingDuration -= 1
            return updatedEffect
        }.filter { $0.remainingDuration > 0 }
    }

    func reset(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
                return
            }
            statusComponent.activeEffects = []
        }
        currentDmgOverTimeStatusEffects = []
    }

    func addEffect(_ effect: StatusEffect, _ entity: GameStateEntity) {
        guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
            return
        }
        if checkIfStatusEffectIsDmgOverTime(effect) {
            self.currentDmgOverTimeStatusEffects.append(effect)
        } else {
            statusComponent.activeEffects.append(effect)
        }
    }
    
    private func checkIfStatusEffectIsDmgOverTime(_ effect: StatusEffect) -> Bool {
        allDmgOverTimeStatusEffects.contains(effect.type)
    }

    func checkHasEffect(ofType type: StatusEffectType, _ entity: GameStateEntity) -> Bool {
        guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
            return false
        }
        return statusComponent.activeEffects.contains { $0.type == type }
    }
    
    func checkIfImmobilised(_ entity: GameStateEntity) -> Bool {
        return checkHasEffect(ofType: .stun, entity) ||
            checkHasEffect(ofType: .frozen, entity)
    }
}
