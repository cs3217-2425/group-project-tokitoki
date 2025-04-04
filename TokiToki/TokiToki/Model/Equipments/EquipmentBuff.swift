//
//  Buff.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation

// Base class for equipment buffs.
class EquipmentBuff {
    let value: Int
    let description: String
    let affectedStat: String

    init(value: Int, description: String, affectedStat: String) {
        self.value = value
        self.description = description
        self.affectedStat = affectedStat
    }
}

// StatBuff is a subclass of EquipmentBuff that represents a buff affecting multiple stats.
class StatBuff: EquipmentBuff {
    let attack: Int
    let defense: Int
    let speed: Int

    init(attack: Int, defense: Int, speed: Int, description: String = "Stat Buff", affectedStat: String = "all") {
        self.attack = attack
        self.defense = defense
        self.speed = speed
        let totalValue = attack + defense + speed
        super.init(value: totalValue, description: description, affectedStat: affectedStat)
    }
}

/// CombinedBuffComponent wraps a StatBuff so it can be applied to a StatsComponent.
class CombinedBuffComponent: EquipmentComponent {
    let buff: StatBuff

    init(buff: StatBuff) {
        self.buff = buff
    }

    func apply(to stats: inout StatsComponent) {
        stats.baseStats.attack += buff.attack
        stats.baseStats.defense += buff.defense
        stats.baseStats.speed += buff.speed
    }

    func remove(from stats: inout StatsComponent) {
        stats.baseStats.attack -= buff.attack
        stats.baseStats.defense -= buff.defense
        stats.baseStats.speed -= buff.speed
    }
}
