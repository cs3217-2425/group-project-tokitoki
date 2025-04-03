//
//  Equipment.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation

enum EquipmentType {
    case consumable
    case nonConsumable
}

protocol Equipment {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var equipmentType: EquipmentType { get }
    var rarity: Int { get }  // e.g., common, rare, epic
}
