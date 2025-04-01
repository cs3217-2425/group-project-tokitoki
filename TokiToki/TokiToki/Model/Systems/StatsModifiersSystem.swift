//
//  StatsModifiersSystem.swift
//  TokiToki
//
//  Created by proglab on 1/4/25.
//

import Foundation

class StatsModifiersSystem: System {
    var priority = 1
    
    func update(_ entities: [GameStateEntity]) {
        entities.forEach { updateModifiers($0) }
    }
    
    func addModifier(_ statsModifier: StatsModifier, _ entity: GameStateEntity) {
        guard let statsModifiersComponent = entity.getComponent(ofType: StatsModifiersComponent.self) else {
            return
        }
        statsModifiersComponent.statsModifiers.append(statsModifier)
    }

    func removeModifier(_ statsModifier: StatsModifier, _ entity: GameStateEntity) {
        guard let statsModifiersComponent = entity.getComponent(ofType: StatsModifiersComponent.self) else {
            return
        }
        statsModifiersComponent.statsModifiers.removeAll { $0 == statsModifier }
    }

    func updateModifiers(_ entity: GameStateEntity) {
        guard let statsModifiersComponent = entity.getComponent(ofType: StatsModifiersComponent.self) else {
            return
        }
        statsModifiersComponent.statsModifiers = statsModifiersComponent.statsModifiers.map { modifier in
            var updatedModifier = modifier
            updatedModifier.remainingDuration -= 1
            return updatedModifier
        }.filter { $0.remainingDuration > 0 }
    }
    
    func reset(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statsModifiersComponent = entity.getComponent(ofType: StatsModifiersComponent.self) else {
                return
            }
            statsModifiersComponent.statsModifiers = []
        }
    }
}
