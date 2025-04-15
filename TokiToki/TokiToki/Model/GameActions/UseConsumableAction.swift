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
    let globalEffectsManager: GlobalStatusEffectsManaging

    init(user: GameStateEntity, consumable: ConsumableEquipment, _ equipmentSystem: EquipmentSystem,
         _ equipmentComponent: EquipmentComponent, _ globalStatusEffectsManager: GlobalStatusEffectsManaging) {
        self.user = user
        self.consumable = consumable
        self.equipmentSystem = equipmentSystem
        self.equipmentComponent = equipmentComponent
        self.globalEffectsManager = globalStatusEffectsManager
    }

    func execute() -> [EffectResult] {
        let results = equipmentSystem.useConsumable(consumable, on: nil, orOn: user, in: equipmentComponent,
                                                    globalEffectsManager)

        return results ?? []
    }
}
