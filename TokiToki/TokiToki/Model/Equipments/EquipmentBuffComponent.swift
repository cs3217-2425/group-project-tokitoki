//
//  EquipmentBuffComponent.swift
//  TokiToki
//
//  Created by Wh Kang on 18/4/25.
//


import Foundation

/// A component that applies/removes an EquipmentBuff on a StatsComponent.
final class EquipmentBuffComponent: EquipmentComponent {
    let buff: EquipmentBuff

    init(buff: EquipmentBuff) {
        self.buff = buff
    }

    /// Applies the buff value to each targeted stat.
    func apply(to stats: inout StatsComponent) {
        for stat in buff.affectedStats {
            switch stat {
            case .attack:
                stats.baseStats.attack += buff.value
            case .defense:
                stats.baseStats.defense += buff.value
            case .speed:
                stats.baseStats.speed += buff.value
            }
        }
    }

    /// Removes the buff value from each targeted stat.
    func remove(from stats: inout StatsComponent) {
        for stat in buff.affectedStats {
            switch stat {
            case .attack:
                stats.baseStats.attack -= buff.value
            case .defense:
                stats.baseStats.defense -= buff.value
            case .speed:
                stats.baseStats.speed -= buff.value
            }
        }
    }
}
