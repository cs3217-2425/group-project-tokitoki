//
//  StatsComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class StatsComponent: Component {
    let entity: Entity
    var currentHealth: Int
    var elementType: [ElementType]
    var actionMeter: Float = 0
    var baseStats: TokiBaseStats

    init(entity: Entity, baseStats: TokiBaseStats, elementType: [ElementType]) {
        self.baseStats = baseStats
        self.currentHealth = baseStats.hp
        self.elementType = elementType
        self.entity = entity
    }
}
