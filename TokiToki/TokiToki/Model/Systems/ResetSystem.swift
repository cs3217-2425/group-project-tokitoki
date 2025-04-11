//
//  ResetSystem.swift
//  TokiToki
//
//  Created by proglab on 26/3/25.
//

class ResetSystem: System {
    var priority = 1
    private var systems: [System] = []

    init() {
        systems.append(SkillsSystem())
        systems.append(StatsSystem())
        systems.append(StatusEffectsSystem.shared)
        systems.append(StatsModifiersSystem())
        systems.append(TurnSystem.shared)
//        systems.append(EquipmentSystem.shared)
    }

    func reset(_ entities: [GameStateEntity]) {
        for system in systems {
            system.reset(entities)
        }
    }

    func update(_ entities: [GameStateEntity]) {
        // update does nothing for reset system
    }
}
