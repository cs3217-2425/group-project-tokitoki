//
//  StatusEffectsSystem.swift
//  TokiToki
//
//  Created by proglab on 26/3/25.
//

import Foundation

class StatusEffectsSystem: System {
    private var statusEffectApplierAndPublisherDelegate: StatusEffectApplierAndPublisherDelegate?

    func setDelegate(_ delegate: StatusEffectApplierAndPublisherDelegate) {
        self.statusEffectApplierAndPublisherDelegate = delegate
    }

    func update(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
                return
            }

            for effect in statusComponent.activeEffects {
                statusEffectApplierAndPublisherDelegate?
                    .applyStatusEffectAndPublishResult(effect, entity)
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

    func reset(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
                return
            }
            statusComponent.activeEffects = []
        }
    }

    func addEffect(_ effect: StatusEffect,
                   _ entity: GameStateEntity,
                   _ modifyStatusEffects: (_ statusEffect: StatusEffect,
                                           _ entity: GameStateEntity,
                                           _ statusEffects: inout [StatusEffect]) -> Void) {
        guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
            return
        }
        modifyStatusEffects(effect, entity, &(statusComponent.activeEffects))
    }

    func removeEffect(_ effect: StatusEffect, _ entity: GameStateEntity) {
        guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
            return
        }

        statusComponent.activeEffects.removeAll { $0.type == effect.type }
    }

    func checkHasEffect(ofType type: StatusEffectType, _ entity: GameStateEntity) -> Bool {
        guard let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) else {
            return false
        }
        return statusComponent.activeEffects.contains { $0.type == type }
    }

    func checkIfImmobilised(_ entity: GameStateEntity) -> Bool {
        checkHasEffect(ofType: .stun, entity) ||
        checkHasEffect(ofType: .frozen, entity) ||
        checkHasEffect(ofType: .paralysis, entity)
    }
}
