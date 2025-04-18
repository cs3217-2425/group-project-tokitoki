//
//  StatusEffectApplierAndPublisherDelegate.swift
//  TokiToki
//
//  Created by proglab on 14/4/25.
//

protocol StatusEffectApplierAndPublisherDelegate {
    func applyStatusEffectAndPublishResult(_ effect: StatusEffect, _ entity: GameStateEntity) -> Bool
}
