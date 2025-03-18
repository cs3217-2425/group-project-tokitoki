//
//  temp.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class BattleSystem {
    private var gameState: GameState
    private var playerTeam: [PlayerEntity]
    private var monsterTeam: [MonsterEntity]
    private var currentTurn: TurnState
    private var activeEntityIndex: Int
    private var pendingActions: [Action] = []
    private var battleLog: [String] = []
    private var effectCalculatorFactory: EffectCalculatorFactory
    private var elementsSystem = ElementsSystem()

    init(playerTeam: [PlayerEntity], monsterTeam: [MonsterEntity], effectCalculatorFactory: EffectCalculatorFactory) {
        self.gameState = GameState(
            elementsSystem: self.elementsSystem,
            statusEffectStrategyFactory: StatusEffectStrategyFactory()
        )
        self.playerTeam = playerTeam
        self.monsterTeam = monsterTeam
        self.currentTurn = .playerTurn
        self.activeEntityIndex = 0
        self.effectCalculatorFactory = effectCalculatorFactory

        // Add all entities to the game state
        for entity in playerTeam {
            gameState.addEntity(entity)
        }

        for entity in monsterTeam {
            gameState.addEntity(entity)
        }
    }

    func startBattle() {
        // Calculate initial turn order
        if useSpeedBasedTurnOrder {
            gameState.calculateTurnOrder()
        } else {
            // Default to player turn first
            currentTurn = .playerTurn
        }

        // Log battle start
        logMessage("Battle started!")
    }

    func queueAction(_ action: Action) {
        pendingActions.append(action)
    }

    func executeNextAction() -> [EffectResult] {
        guard !pendingActions.isEmpty else {
            return []
        }

        let action = pendingActions.removeFirst()
        return action.execute(gameState: gameState)
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
        for monster in monsterTeam {
            if monster.isDead() {
                continue
            }

            if let aiComponent = monster.getComponent(ofType: AIComponent.self) {
                let action = aiComponent.determineAction(gameState: gameState)
                let results = action.execute(gameState: gameState)

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
        let allEntities = playerTeam + monsterTeam

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
                let strategyFactory = gameState.getStatusEffectStrategyFactory()

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
        monsterTeam = monsterTeam.filter { !$0.isDead() }
    }

    private func isBattleOver() -> Bool {
        playerTeam.isEmpty || monsterTeam.isEmpty
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

    func getGameState() -> GameState {
        gameState
    }

    func getCurrentTurn() -> TurnState {
        currentTurn
    }

    func getBattleLog() -> [String] {
        battleLog
    }
}
