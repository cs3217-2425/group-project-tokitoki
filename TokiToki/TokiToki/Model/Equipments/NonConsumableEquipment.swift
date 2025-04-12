//
//  NonConsumableEquipment.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

struct NonConsumableEquipment: Equipment {
    let id: UUID
    let name: String
    let description: String
    let equipmentType: EquipmentType = .nonConsumable
    let rarity: Int
    let buff: EquipmentBuff
    let slot: EquipmentSlot
}

extension NonConsumableEquipment {
    var components: [Any] {
        let statBuff = StatBuff(attack: buff.value, defense: buff.value, speed: buff.value)
        return [CombinedBuffComponent(buff: statBuff)]
    }
}
