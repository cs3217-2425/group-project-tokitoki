//
//  ECS.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// ECS Manager
class ECSManager {
    static let shared = ECSManager()

    private var entities: [UUID: Entity] = [:]
    private var systems: [System] = []

    private init() {}

    func addEntity(_ entity: Entity) {
        entities[entity.id] = entity
    }

    func removeEntity(_ entity: Entity) {
        entities.removeValue(forKey: entity.id)
    }

    func getEntity(id: UUID) -> Entity? {
        entities[id]
    }

    func getAllEntities() -> [Entity] {
        Array(entities.values)
    }

    func addSystem(_ system: System) {
        systems.append(system)
        systems.sort { $0.priority < $1.priority }
    }

    func update(deltaTime: TimeInterval) {
        for system in systems {
            system.update(deltaTime: deltaTime)
        }
    }
}
