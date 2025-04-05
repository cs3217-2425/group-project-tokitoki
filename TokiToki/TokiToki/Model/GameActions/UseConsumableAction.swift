//
//  EndTurnAction.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class UseConsumableAction: Action {
    let user: GameStateEntity
    let consumable: ConsumableEquipment

    init(user: GameStateEntity, consumable: ConsumableEquipment) {
        self.user = user
        self.consumable = consumable
    }
    
    func execute() -> [EffectResult] {
        let results = EquipmentSystem.shared.useConsumable(consumable, on: nil, user)
        
        return results ?? []
    }
}
