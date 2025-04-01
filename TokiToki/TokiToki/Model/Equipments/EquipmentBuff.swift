//
//  Buff.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation

/// A simple struct that represents a buff with flat bonuses.
struct Buff {
    let attack: Int
    let defense: Int
    let speed: Int
}

/// EquipmentComponent defines how a buff component can be applied to or removed from a StatsComponent.
protocol EquipmentComponent {
    func apply(to stats: inout StatsComponent)
    func remove(from stats: inout StatsComponent)
}

/// CombinedBuffComponent wraps a Buff so it conforms to EquipmentComponent.
class CombinedBuffComponent: EquipmentComponent {
    let buff: Buff

    init(buff: Buff) {
        self.buff = buff
    }

    func apply(to statsComponent: inout StatsComponent) {
        statsComponent.baseStats.attack += buff.attack
        statsComponent.baseStats.defense += buff.defense
        statsComponent.baseStats.speed += buff.speed
    }

    func remove(from statsComponent: inout StatsComponent) {
        statsComponent.baseStats.attack -= buff.attack
        statsComponent.baseStats.defense -= buff.defense
        statsComponent.baseStats.speed -= buff.speed
    }
}
