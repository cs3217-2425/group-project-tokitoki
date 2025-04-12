//
//  ConsumableEquipment.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

enum ConsumableUsageContext {
    case battleOnly
    case outOfBattleOnly
    case anywhere
}

struct ConsumableEquipment: Equipment {
    let id: UUID
    let name: String
    let description: String
    let equipmentType: EquipmentType = .consumable
    let rarity: Int
    let effectStrategy: ConsumableEffectStrategy
    let usageContext: ConsumableUsageContext
}
