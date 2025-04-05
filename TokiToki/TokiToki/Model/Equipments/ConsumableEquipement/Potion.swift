//
//  Potion.swift
//  TokiToki
//
//  Created by proglab on 5/4/25.
//

import Foundation

class Potion: ConsumableEquipment {
    var id: UUID = UUID()
    var name: String
    var description: String
    var equipmentType: EquipmentType = .consumable
    var rarity: Int
    let effectCalculators: [EffectCalculator]
    
    init(name: String, description: String, rarity: Int, effectCalculators: [EffectCalculator]) {
        self.name = name
        self.description = description
        self.rarity = rarity
        self.effectCalculators = effectCalculators
    }

    func applyEffect(to toki: Toki?, _ entity: GameStateEntity?, completion: (() -> Void)? = nil)
    -> [EffectResult]? {
        guard let entity = entity else {
            return nil
        }
        var results: [EffectResult] = []
        for effectCalculator in effectCalculators {
            let result = effectCalculator.calculate(moveName: name,
                                                    source: entity, target: entity)
            guard let result = result else {
                continue
            }
            results.append(result)
        }
        completion?()
        return results
    }
}
