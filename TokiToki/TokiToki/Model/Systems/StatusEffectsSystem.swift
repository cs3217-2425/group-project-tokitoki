//
//  StatusEffectsSystem.swift
//  TokiToki
//
//  Created by proglab on 26/3/25.
//

class StatusEffectsSystem {
    var priority = 1
    private let strategyFactory = StatusEffectStrategyFactory()
    
    func update(_ entities: [GameStateEntity], _ logMessage: (String) -> Void) { // Check that this callback works
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
    
    private func updateEffects(_ statusComponent: StatusEffectsComponent) {
        statusComponent.activeEffects = statusComponent.activeEffects.map { effect in
            var updatedEffect = effect
            updatedEffect.remainingDuration -= 1
            return updatedEffect
        }.filter { $0.remainingDuration > 0 }
    }
}
