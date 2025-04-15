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
    let context: EffectCalculationContext

    init(user: GameStateEntity, consumable: ConsumableEquipment, _ equipmentSystem: EquipmentSystem,
         _ equipmentComponent: EquipmentComponent, _ context: EffectCalculationContext) {
        self.user = user
        self.consumable = consumable
        self.equipmentSystem = equipmentSystem
        self.equipmentComponent = equipmentComponent
        self.context = context
    }

    func execute() -> [EffectResult] {
        let results = equipmentSystem.useConsumable(consumable, on: nil, orOn: user, in: equipmentComponent,
                                                    context)

        return results ?? []
    }
}
