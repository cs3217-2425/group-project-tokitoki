//
//  ConsumableEquipment.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//


import Foundation

struct ConsumableEquipment: Equipment {
    let id: UUID = UUID()
    let name: String
    let description: String
    let equipmentType: EquipmentType = .consumable
    let rarity: Int
    let effectStrategy: ConsumableEffectStrategy
}