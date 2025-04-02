//
//  EquipmentRepository.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation

class EquipmentRepository {
    static let shared = EquipmentRepository()
    private init() {}
    
    func createConsumableEquipment(name: String, description: String, rarity: Int, effectStrategy: ConsumableEffectStrategy) -> ConsumableEquipment {
        return ConsumableEquipment(name: name, description: description, rarity: rarity, effectStrategy: effectStrategy)
    }
    
    func createNonConsumableEquipment(name: String, description: String, rarity: Int,
                                      buff: EquipmentBuff, slot: EquipmentSlot) -> NonConsumableEquipment {
        return NonConsumableEquipment(name: name, description: description, rarity: rarity, buff: buff, slot: slot)
    }
}
