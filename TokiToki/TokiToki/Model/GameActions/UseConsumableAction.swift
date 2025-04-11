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
    let equipmentSystem: EquipmentSystem
    let equipmentComponent: EquipmentComponent

    init(user: GameStateEntity, consumable: ConsumableEquipment, _ equipmentSystem: EquipmentSystem,
         _ equipmentComponent: EquipmentComponent) {
        self.user = user
        self.consumable = consumable
        self.equipmentSystem = equipmentSystem
        self.equipmentComponent = equipmentComponent
    }

    func execute() -> [EffectResult] {
        let results = equipmentSystem.useConsumable(consumable, on: nil, orOn: user, in: equipmentComponent)

        return results ?? []
    }
}
