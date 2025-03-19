//
//  GameState.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class TurnManager {
    private var entities: [UUID: Entity] = [:]
    private var currentTurn: TurnState
    private var turnOrder: [UUID] = []
    private var activeEntityIndex: Int = 0
    private var elementEffectivenessSystem: ElementEffectivenessSystem
    private var statusEffectStrategyFactory: StatusEffectStrategyFactory

    init(elementEffectivenessSystem: ElementEffectivenessSystem,
         statusEffectStrategyFactory: StatusEffectStrategyFactory, startTurn: TurnState) {
        self.currentTurn = startTurn
        self.elementEffectivenessSystem = elementEffectivenessSystem
        self.statusEffectStrategyFactory = statusEffectStrategyFactory
    }

    func addEntity(_ entity: Entity) {
        entities[entity.id] = entity
    }

    func getEntity(id: UUID) -> Entity? {
        entities[id]
    }

    func getAllEntities() -> [Entity] {
        Array(entities.values)
    }

    func getPlayerEntities() -> [Entity] {
        entities.values.filter { $0 is TokiGameStateEntity }
    }

    func getMonsterEntities() -> [Entity] {
        entities.values.filter { $0 is OpponentGameStateEntity }
    }

    func calculateTurnOrder() {
        var entitiesWithSpeed: [(UUID, Int)] = []

        for entity in entities.values {
            if let statsComponent = entity.getComponent(ofType: StatsComponent.self) {
                entitiesWithSpeed.append((entity.id, statsComponent.speed))
            }
        }

        // Sort by speed in descending order
        entitiesWithSpeed.sort { $0.1 > $1.1 }

        // Extract just the entity IDs
        turnOrder = entitiesWithSpeed.map { $0.0 }
        activeEntityIndex = 0
    }

    func getActiveEntity() -> Entity? {
        guard !turnOrder.isEmpty && activeEntityIndex < turnOrder.count else {
            return nil
        }

        let activeEntityId = turnOrder[activeEntityIndex]
        return entities[activeEntityId]
    }

    func nextTurn() {
        activeEntityIndex += 1

        if activeEntityIndex >= turnOrder.count {
            activeEntityIndex = 0

            // Update all entities for the new turn
            for entity in entities.values {
                updateEntityForNewTurn(entity)
            }
        }

        // Check if the current entity can act
        if let activeEntity = getActiveEntity(),
           let statusComponent = activeEntity.getComponent(ofType: StatusEffectsComponent.self),
           statusComponent.hasEffect(ofType: .stun) || statusComponent.hasEffect(ofType: .frozen) {
            // Skip stunned or frozen entities
            nextTurn()
        }
    }

    private func updateEntityForNewTurn(_ entity: Entity) {
        // Reduce cooldowns
        if let skillsComponent = entity.getComponent(ofType: SkillsComponent.self) {
            for skill in skillsComponent.skills {
                skill.reduceCooldown()
            }
        }

        // Process status effects
        if let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) {
            let effects = statusComponent.activeEffects
            for effect in effects {
                _ = effect.apply(to: entity, strategyFactory: statusEffectStrategyFactory)
            }
            statusComponent.updateEffects()
        }
    }

    func isGameOver() -> Bool {
        let playerEntities = getPlayerEntities()
        let monsterEntities = getMonsterEntities()

        return playerEntities.isEmpty || monsterEntities.isEmpty
    }

    func getElementEffectivenessSystem() -> ElementEffectivenessSystem {
        elementEffectivenessSystem
    }

    func getStatusEffectStrategyFactory() -> StatusEffectStrategyFactory {
        statusEffectStrategyFactory
    }
}



