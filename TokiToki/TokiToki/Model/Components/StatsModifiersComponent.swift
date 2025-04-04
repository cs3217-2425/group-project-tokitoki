//
//  StatModifiersComponent.swift
//  TokiToki
//
//  Created by proglab on 31/3/25.
//

import Foundation

class StatsModifiersComponent: Component {
    var statsModifiers: [StatsModifier]
    let entity: Entity

    init(entity: Entity) {
        self.statsModifiers = []
        self.entity = entity
    }
}

struct StatsModifier: Equatable {
    var remainingDuration: Int
    let attack: Double
    let defense: Double
    let speed: Double
    let heal: Double
    let criticalHitChance: Double
    let criticalHitDmg: Double
    
    init(remainingDuration: Int, attack: Double = 1.0, defense: Double = 1.0, speed: Double = 1.0,
         heal: Double = 1.0, criticalHitChance: Double = 1.0, criticalHitDmg: Double = 1.0) {
        self.remainingDuration = remainingDuration
        self.attack = attack
        self.defense = defense
        self.speed = speed
        self.heal = heal
        self.criticalHitChance = criticalHitChance
        self.criticalHitDmg = criticalHitDmg
    }

    func describeChanges(for entity: GameStateEntity) -> String {
        var changes: [String] = []

        func formatChange(stat: String, multiplier: Double) -> String? {
            let percentageChange = (multiplier - 1) * 100
            if percentageChange == 0 { return nil }

            let direction = percentageChange > 0 ? "increased" : "decreased"
            return "\(stat) \(direction) by \(abs(Int(percentageChange)))%"
        }

        if let attackChange = formatChange(stat: "Attack", multiplier: Double(attack)) {
            changes.append(attackChange)
        }
        if let defenseChange = formatChange(stat: "Defense", multiplier: Double(defense)) {
            changes.append(defenseChange)
        }
        if let speedChange = formatChange(stat: "Speed", multiplier: Double(speed)) {
            changes.append(speedChange)
        }
        if let critChanceChange = formatChange(stat: "Critical Hit Chance", multiplier: criticalHitChance) {
            changes.append(critChanceChange)
        }
        if let critDmgChange = formatChange(stat: "Critical Hit Damage", multiplier: criticalHitDmg) {
            changes.append(critDmgChange)
        }

        return changes.isEmpty ? "No stat changes"
        : "\(entity.name)'s stats have changed for \(remainingDuration) turns! " + changes.joined(separator: ", ")
    }
}
