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
    let attack: Int
    let defense: Int
    let speed: Int
    let heal: Int
    
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
        
        return changes.isEmpty ? "No stat changes"
        : "\(entity.name)'s stats have changed for \(remainingDuration) turns! " + changes.joined(separator: ", ")
    }
}


