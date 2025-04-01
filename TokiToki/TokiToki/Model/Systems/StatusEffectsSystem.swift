//
//  StatusEffectsSystem.swift
//  TokiToki
//
//  Created by proglab on 26/3/25.
//

import Foundation

class StatusEffectsSystem: System {
    var priority = 1
    private let strategyFactory = StatusEffectStrategyFactory()

    func update(_ entities: [GameStateEntity], _ logMessage: (String) -> Void) {
        for entity in entities {
            guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
                return
            }

            for effect in statusComponent.activeEffects {
                let result = effect.apply(to: entity, strategyFactory: strategyFactory)
                logMessage(result.description)

                // Publish StatusEffectApplied result
                for event in result.toBattleEvents(sourceId: effect.sourceId) {
                    print(event)
                    EventBus.shared.post(event)
                }
            }

            updateEffects(statusComponent)
        }
    }
    
    func update(_ entities: [GameStateEntity]) {
        
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
    }
    
    func addEffect(_ effect: StatusEffect, _ entity: GameStateEntity) {
        guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
            return
        }
        statusComponent.activeEffects.append(effect)
    }

    func removeEffect(_ statusEffect: StatusEffect, _ entity: GameStateEntity) {
        guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
            return
        }
        statusComponent.activeEffects.removeAll { $0 == statusEffect }
    }

    func checkHasEffect(ofType type: StatusEffectType, _ entity: GameStateEntity) -> Bool {
        guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
            return false
        }
        return statusComponent.activeEffects.contains { $0.type == type }
    }
}
