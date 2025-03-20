//
//  temp.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class GameEngine {
    private var playerTeam: [GameStateEntity]
    private var opponentTeam: [GameStateEntity]
    private var playersPlusOpponents: [GameStateEntity] = []
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
    private var battleEffectsDelegate: BattleEffectsDelegate?

    init(playerTeam: [GameStateEntity], opponentTeam: [GameStateEntity]) {
        self.playerTeam = playerTeam
        self.opponentTeam = opponentTeam
        self.currentTurn = .playerTurn
        self.effectCalculatorFactory = EffectCalculatorFactory()
        self.playersPlusOpponents = playerTeam + opponentTeam
    }

    func startBattle() {
        logMessage("Battle started!")
        if useSpeedBasedTurnOrder {
            
            startGameLoop()
        } else {
            // Default to player turn first
            currentTurn = .playerTurn
        }
    }

    func addObserver(_ battleLogObserver: BattleLogObserver) {
        self.battleLogObserver = battleLogObserver
    }
    
    func addDelegate(_ battleEffectsDelegate: BattleEffectsDelegate) {
        self.battleEffectsDelegate = battleEffectsDelegate
    }

    func startGameLoop() {
        while !isBattleOver() {
            currentGameStateEntity = getNextReadyCharacter()
            
            guard let currentGameStateEntity = currentGameStateEntity else {
                updateAllActionMeters()
                continue
            }

            guard let statusComponent = currentGameStateEntity.getComponent(ofType: StatusEffectsComponent.self) else {
                return
            }

            if statusComponent.hasEffect(ofType: .stun) || statusComponent.hasEffect(ofType: .frozen) {
                updateEntityForNewTurn(currentGameStateEntity)
                continue
            }

            if (opponentTeam.contains{ $0.id == currentGameStateEntity.id } ) {
                executeOpponentTurn(currentGameStateEntity)
                updateEntityForNewTurn(currentGameStateEntity)
                continue
            }

            updateSkillIconsForCurrentEntity(currentGameStateEntity)
            return
        }
    }
    
    private func updateAllActionMeters() {
        for entity in playersPlusOpponents {
            entity.incrementActionBar(by: 0.1)
        }
    }
    
    private func getNextReadyCharacter() -> GameStateEntity? {
        let readyEntities = playersPlusOpponents.filter { $0.getActionBar() >= 100 }
        
        if readyEntities.isEmpty {
            return nil
        } else if readyEntities.count == 1 {
            return readyEntities[0]
        } else {
            let sortedEntities = readyEntities.sorted {
                if $0.getActionBar() == $1.getActionBar() {
                    return $0.getSpeed() > $1.getSpeed()
                }
                return $0.getActionBar() > $1.getActionBar()
            }

            return sortedEntities.first
        }
    }
    
    private func updateSkillIconsForCurrentEntity(_ currentGameStateEntity: GameStateEntity) {
        let skillsAvailable = currentGameStateEntity.getComponent(ofType: SkillsComponent.self)?.skills
        let skillIcons = skillsAvailable?.map { skill in
            let skillIcon = skillsToIconImage[skill.name]
            guard let skillIcon = skillIcon else {
                return ""
            }
            return skillIcon
        }
        battleEffectsDelegate?.updateSkillIcons(skillIcons)
    }

    func useTokiSkill(_ skillIndex: Int) {
        guard let currentGameStateEntity = currentGameStateEntity else {
            return
        }
        let skillSelected = currentGameStateEntity.getComponent(ofType: SkillsComponent.self)?.skills[skillIndex]
        guard let skillSelected = skillSelected else {
            return
        }

        // TODO: account for target selection instead of passing in the whole opponentTeam to targets
        let action = UseSkillAction(user: currentGameStateEntity, skill: skillSelected, targets: opponentTeam)

        queueAction(action)
        let results = executeNextAction()
        battleEffectsDelegate?.showUseSkill(currentGameStateEntity.id) { [weak self] in
            self?.updateLogAfterSkillUse(results, currentGameStateEntity)
        }
    }
    
    fileprivate func updateLogAfterSkillUse(_ results: [EffectResult], _ currentGameStateEntity: GameStateEntity) {
        for result in results {
            logMessage(result.description)
        }
        updateEntityForNewTurn(currentGameStateEntity)
        startGameLoop()
    }

    func queueAction(_ action: Action) {
        pendingActions.append(action)
    }


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
            let action = aiComponent.determineAction(entity, playerTeam)
            let results = action.execute()
            battleEffectsDelegate?.showUseSkill(entity.id) {}
            
            for result in results {
                logMessage(result.description)
            }
        }
    }

    func updateEntityForNewTurn(_ entity: GameStateEntity) {
        if entity.isDead() {
            playersPlusOpponents.removeAll { $0.id == entity.id }
            playerTeam.removeAll { $0.id == entity.id }
            opponentTeam.removeAll { $0.id == entity.id }
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
        
        entity.resetActionBar()
    }

    private func isBattleOver() -> Bool {
        if playerTeam.isEmpty {
            logMessage("Battle ended! The monsters won!")
        } else if opponentTeam.isEmpty {
            logMessage("Battle ended! The player won!")
        }
        return playerTeam.isEmpty || opponentTeam.isEmpty
    }

    private func logMessage(_ message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.battleLog.append(message)
        }
    }

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
