//
//  ResetSystem.swift
//  TokiToki
//
//  Created by proglab on 26/3/25.
//

class ResetSystem {
    private var systems: [System] = []
//    private let statsSystem = StatsSystem()
//    private let skillSystem = SkillsSystem()
//    private let statusEffectsSystem = StatusEffectsSystem()
    
    init() {
        systems.append(SkillsSystem())
        systems.append(StatsSystem())
        systems.append(StatusEffectsSystem())
    }
    
    func update(_ entities: [GameStateEntity]) {
        for system in systems {
            system.reset(entities)
        }
    }
}
