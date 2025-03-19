//
//  temp.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class GameEngine {
    //private var turnManager: TurnManager
    private var playerTeam: [GameStateEntity]
    private var opponentTeam: [GameStateEntity]
    private var currentTurn: TurnState
    private var activeEntityIndex: Int
    private var pendingActions: [Action] = []
    private var battleLog: [String] = []
    private var effectCalculatorFactory: EffectCalculatorFactory
    private var elementEffectivenessSystem = ElementEffectivenessSystem()
    private var statusEffectStrategyFactory = StatusEffectStrategyFactory()
    private var entities: [UUID: GameStateEntity] = [:]
    private var turnOrder: [GameStateEntity] = []

    init(playerTeam: [TokiGameStateEntity], opponentTeam: [OpponentGameStateEntity], effectCalculatorFactory: EffectCalculatorFactory) {
//        self.turnManager = TurnManager(
//            elementEffectivenessSystem: self.elementEffectivenessSystem,
//            statusEffectStrategyFactory: StatusEffectStrategyFactory(),
//            startTurn: .playerTurn
//        )
        self.playerTeam = playerTeam
        self.opponentTeam = opponentTeam
        self.currentTurn = .playerTurn
        self.activeEntityIndex = 0
        self.effectCalculatorFactory = effectCalculatorFactory
        //self.entities = (playerTeam + opponentTeam).map{entities[entity.id] = entity}

//        // Add all entities to the game state
//        for entity in playerTeam {
//            turnManager.addEntity(entity)
//        }
//
//        for entity in monsterTeam {
//            turnManager.addEntity(entity)
//        }
    }

    func startBattle() {
        // Calculate initial turn order
        if useSpeedBasedTurnOrder {
            calculateTurnOrder()
        } else {
            // Default to player turn first
            currentTurn = .playerTurn
        }

        // Log battle start
        logMessage("Battle started!")
    }
    
    func useTokiSkill(_ skillIndex: Int)  {
        let currentGameStateEntity = turnOrder[activeEntityIndex]
        let skillSelected = currentGameStateEntity.getComponent(ofType: SkillsComponent.self)?.skills[skillIndex]
        guard let skillSelected = skillSelected else {
            return
        }
        
        // TODO: account for target selection instead of passing in the whole opponentTeam to targets
        let action = UseSkillAction(user: currentGameStateEntity, skill: skillSelected, targets: opponentTeam)
        
        queueAction(action)
        let result = executeNextAction()
        // call observer to update ui with the result
    }

    func queueAction(_ action: Action) {
        pendingActions.append(action)
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

    func executeNextAction() -> [EffectResult] {
        guard !pendingActions.isEmpty else {
            return []
        }

        let action = pendingActions.removeFirst()
        return action.execute(gameState: turnManager)
    }

    func endTurn() {
        if currentTurn == .playerTurn {
            currentTurn = .monsterTurn
            executeMonsterTurn()
        } else {
            currentTurn = .playerTurn

            // Update status effects, cooldowns, etc.
            updateEntitiesForNewTurn()
        }

        // Remove defeated entities
        removeDefeatedEntities()

        // Check if the battle is over
        if isBattleOver() {
            endBattle()
        }
    }

    private func executeMonsterTurn() {
        for monster in opponentTeam {
            if monster.isDead() {
                continue
            }

            if let aiComponent = monster.getComponent(ofType: AIComponent.self) {
                let action = aiComponent.determineAction(gameState: turnManager)
                let results = action.execute(gameState: turnManager)

                // Log the results
                for result in results {
                    logMessage(result.description)
                }
            }
        }

        // Automatically end the monster turn
        currentTurn = .playerTurn
    }

    private func updateEntitiesForNewTurn() {
        let allEntities = playerTeam + opponentTeam

        for entity in allEntities {
            // Skip defeated entities
            if entity.isDead() {
                continue
            }

            // Update skill cooldowns
            if let skillsComponent = entity.getComponent(ofType: SkillsComponent.self) {
                for skill in skillsComponent.skills {
                    skill.reduceCooldown()
                }
            }

            // Process status effects
            if let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) {
                let strategyFactory = statusEffectStrategyFactory

                for effect in statusComponent.activeEffects {
                    let result = effect.apply(to: entity, strategyFactory: strategyFactory)
                    logMessage(result.description)
                }

                statusComponent.updateEffects()
            }
        }
    }

    private func removeDefeatedEntities() {
        playerTeam = playerTeam.filter { !$0.isDead() }
        opponentTeam = opponentTeam.filter { !$0.isDead() }
    }

    private func isBattleOver() -> Bool {
        playerTeam.isEmpty || opponentTeam.isEmpty
    }

    private func endBattle() {
        if playerTeam.isEmpty {
            logMessage("Battle ended! The monsters won!")
        } else {
            logMessage("Battle ended! The player won!")
        }
    }

    private func logMessage(_ message: String) {
        battleLog.append(message)
    }

    var useSpeedBasedTurnOrder: Bool = false

//    func getGameState() -> TurnManager {
//        turnManager
//    }

    func getCurrentTurn() -> TurnState {
        currentTurn
    }

    func getBattleLog() -> [String] {
        battleLog
    }
}

enum TurnState {
    case playerTurn
    case monsterTurn
}
