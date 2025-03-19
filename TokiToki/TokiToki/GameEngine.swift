//
//  temp.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class GameEngine {
    private var playerTeam: [UUID: GameStateEntity]
    private var opponentTeam: [UUID: GameStateEntity]
    private var playersPlusOpponents: [UUID: GameStateEntity] = [:]
    private var currentTurn: TurnState
    private var currentGameStateEntity: GameStateEntity?
    private var isWaitingForSkillSelect: Bool = true
    private var pendingActions: [Action] = []
    private var battleLog: [String] = [] {
        didSet {
            battleLogObserver?.update(log: battleLog)
        }
    }
    private var effectCalculatorFactory: EffectCalculatorFactory
    private var elementsSystem = ElementsSystem()
    private var statusEffectStrategyFactory = StatusEffectStrategyFactory()
    private var useSpeedBasedTurnOrder: Bool = true
    private var battleLogObserver: BattleLogObserver?

    init(playerTeam: [UUID: GameStateEntity], opponentTeam: [UUID: GameStateEntity]) {
        self.playerTeam = playerTeam
        self.opponentTeam = opponentTeam
        self.currentTurn = .playerTurn
        self.effectCalculatorFactory = EffectCalculatorFactory(elementsSystem)
    }

    func startBattle() {
        if useSpeedBasedTurnOrder {
            startGameLoop()
        } else {
            // Default to player turn first
            currentTurn = .playerTurn
        }
        logMessage("Battle started!")
    }
    
    func addObserver(_ battleLogObserver: BattleLogObserver) {
        self.battleLogObserver = battleLogObserver
    }
    
    func startGameLoop() {
        while (!isBattleOver()) {
            for entity in playersPlusOpponents.values {
                entity.incrementActionBar(by: 0.5)
            }
            let readyEntities = playersPlusOpponents.values.filter { $0.getActionBar() >= 100 }

            if readyEntities.isEmpty {
                continue
            } else if readyEntities.count == 1 {
                currentGameStateEntity = readyEntities[0]
            } else {
                let sortedEntities = readyEntities.sorted {
                    if $0.getActionBar() == $1.getActionBar() {
                        return $0.getSpeed() > $1.getSpeed()
                    }
                    return $0.getActionBar() > $1.getActionBar()
                }

                currentGameStateEntity = sortedEntities.first
            }
            guard let currentGameStateEntity = currentGameStateEntity else {
                return
            }
            let statusComponent = currentGameStateEntity.getComponent(ofType: StatusEffectsComponent.self)
            
            guard let statusComponent = statusComponent else {
                return
            }
            
            if statusComponent.hasEffect(ofType: .stun) || statusComponent.hasEffect(ofType: .frozen) {
                updateEntityForNewTurn(currentGameStateEntity)
                continue
            }
            
            if opponentTeam.keys.contains(currentGameStateEntity.id) {
                executeOpponentTurn(currentGameStateEntity)
                updateEntityForNewTurn(currentGameStateEntity)
                continue
            }
            
            isWaitingForSkillSelect = true
            // update observer
            while (isWaitingForSkillSelect) {} // busy waiting
            
            updateEntityForNewTurn(currentGameStateEntity)
        }
    }
    
    func useTokiSkill(_ skillIndex: Int)  {
        guard let currentGameStateEntity = currentGameStateEntity else {
            return
        }
        let skillSelected = currentGameStateEntity.getComponent(ofType: SkillsComponent.self)?.skills[skillIndex]
        guard let skillSelected = skillSelected else {
            return
        }
        
        // TODO: account for target selection instead of passing in the whole opponentTeam to targets
        let action = UseSkillAction(user: currentGameStateEntity, skill: skillSelected, targets: Array(opponentTeam.values))
        
        queueAction(action)
        let results = executeNextAction()
        for result in results {
            logMessage(result.description)
        }
        isWaitingForSkillSelect = false
    }

    func queueAction(_ action: Action) {
        pendingActions.append(action)
    }
    
//    func calculateTurnOrder() {
//        var entitiesWithSpeed: [(GameStateEntity, Int)] = []
//
//        for entity in entities.values {
//            if let statsComponent = entity.getComponent(ofType: StatsComponent.self) {
//                entitiesWithSpeed.append((entity, statsComponent.speed))
//            }
//        }
//
//        // Sort by speed in descending order
//        entitiesWithSpeed.sort { $0.1 > $1.1 }
//
//        // Extract just the entity IDs
//        turnOrder = entitiesWithSpeed.map { $0.0 }
//        activeEntityIndex = 0
//    }

//    func getActiveEntity() -> Entity? {
//        guard !turnOrder.isEmpty && activeEntityIndex < turnOrder.count else {
//            return nil
//        }
//
//        let activeEntityId = turnOrder[activeEntityIndex]
//        return entities[activeEntityId]
//    }
    
//    func nextTurn() {
//        activeEntityIndex += 1
//
//        if activeEntityIndex >= turnOrder.count {
//            activeEntityIndex = 0
//
//            // Update all entities for the new turn
//            for entity in playersPlusOpponents.values {
//                updateEntityForNewTurn(entity)
//            }
//        }
//
//        // Check if the current entity can act
//        if let activeEntity = getActiveEntity(),
//           let statusComponent = activeEntity.getComponent(ofType: StatusEffectsComponent.self),
//           statusComponent.hasEffect(ofType: .stun) || statusComponent.hasEffect(ofType: .frozen) {
//            // Skip stunned or frozen entities
//            nextTurn()
//        }
//    }

    func executeNextAction() -> [EffectResult] {
        guard !pendingActions.isEmpty else {
            return []
        }

        let action = pendingActions.removeFirst()
        return action.execute()
    }

//    func endTurn() {
//        if currentTurn == .playerTurn {
//            currentTurn = .monsterTurn
//            executeMonsterTurn()
//        } else {
//            currentTurn = .playerTurn
//
//            // Update status effects, cooldowns, etc.
//            updateEntitiesForNewTurn()
//        }
//
//        // Remove defeated entities
//        removeDefeatedEntities()
//
//        // Check if the battle is over
//        if isBattleOver() {
//            endBattle()
//        }
//    }

    private func executeOpponentTurn(_ entity: GameStateEntity) {
        if let aiComponent = entity.getComponent(ofType: AIComponent.self) {
            let action = aiComponent.determineAction(entity, Array(opponentTeam.values))
            let results = action.execute()

            for result in results {
                logMessage(result.description)
            }
        }
    }

//    private func updateEntitiesForNewTurn() {
//        let allEntities = playerTeam + opponentTeam
//
//        for entity in allEntities {
//            // Skip defeated entities
//            if entity.isDead() {
//                continue
//            }
//
//            // Update skill cooldowns
//            if let skillsComponent = entity.getComponent(ofType: SkillsComponent.self) {
//                for skill in skillsComponent.skills {
//                    skill.reduceCooldown()
//                }
//            }
//
//            // Process status effects
//            if let statusComponent = entity.getComponent(ofType: StatusEffectsComponent.self) {
//                let strategyFactory = statusEffectStrategyFactory
//
//                for effect in statusComponent.activeEffects {
//                    let result = effect.apply(to: entity, strategyFactory: strategyFactory)
//                    logMessage(result.description)
//                }
//
//                statusComponent.updateEffects()
//            }
//        }
//    }
    
    func updateEntityForNewTurn(_ entity: GameStateEntity) {
        if entity.isDead() {
            playersPlusOpponents.removeValue(forKey: entity.id)
            playerTeam.removeValue(forKey: entity.id)
            opponentTeam.removeValue(forKey: entity.id)
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

//    private func removeDefeatedEntities() {
//        playerTeam = playerTeam.filter { !$0.isDead() }
//        opponentTeam = opponentTeam.filter { !$0.isDead() }
//    }

    private func isBattleOver() -> Bool {
        if playerTeam.isEmpty {
            logMessage("Battle ended! The monsters won!")
        } else {
            logMessage("Battle ended! The player won!")
        }
        return playerTeam.isEmpty || opponentTeam.isEmpty
    }


    private func logMessage(_ message: String) {
        battleLog.append(message)
    }

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
