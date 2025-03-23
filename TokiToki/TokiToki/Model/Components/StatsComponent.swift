//
//  StatsComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class StatsComponent: BaseComponent {
    var maxHealth: Int
    var currentHealth: Int
    var attack: Int
    var defense: Int
    var speed: Int
    var elementType: ElementType
    var actionMeter: Float = 0

    init(entityId: UUID, maxHealth: Int, attack: Int, defense: Int, speed: Int, elementType: ElementType) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        self.attack = attack
        self.defense = defense
        self.speed = speed
        self.elementType = elementType
        super.init(entityId: entityId)
    }
}
