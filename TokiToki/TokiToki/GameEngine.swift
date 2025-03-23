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

//    private var savedPlayerTeam: [GameStateEntity]
//    private var savedOpponentTeam: [GameStateEntity]
//    private var savedPlayersPlusOpponents: [GameStateEntity] = []

    init(playerTeam: [GameStateEntity], opponentTeam: [GameStateEntity]) {
        self.playerTeam = playerTeam
        self.opponentTeam = opponentTeam
        self.currentTurn = .playerTurn
        self.effectCalculatorFactory = EffectCalculatorFactory()
        self.playersPlusOpponents = playerTeam + opponentTeam
//        self.savedPlayerTeam = playerTeam.map{ $0.copy() }
//        self.savedOpponentTeam = opponentTeam.map{ $0.copy() }
//        self.savedPlayersPlusOpponents = savedPlayerTeam + savedOpponentTeam
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
                updateEntityForNewTurnAndAllEntities(currentGameStateEntity)
                continue
            }

            if (opponentTeam.contains { $0.id == currentGameStateEntity.id }) {
                executeOpponentTurn(currentGameStateEntity)
                return
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
                return SkillUiInfo(iconImgString: "", cooldown: skill.currentCooldown)
            }
            return SkillUiInfo(iconImgString: skillIcon, cooldown: skill.currentCooldown)
        }
        battleEffectsDelegate?.updateSkillIcons(skillIcons)
    }

    func useTokiSkill(_ skillIndex: Int, _ targetsSelected: [GameStateEntity]?) {
        guard let currentGameStateEntity = currentGameStateEntity else {
            return
        }
        let skillSelected = currentGameStateEntity.getComponent(ofType: SkillsComponent.self)?.skills[skillIndex]
        guard let skillSelected = skillSelected else {
            return
        }

//        if TargetSelectionFactory().checkIfRequireTargetSelection(skillSelected.targetType) {
//            
//        }

        // TODO: account for target selection instead of passing in the whole opponentTeam to targets
        let action = UseSkillAction(user: currentGameStateEntity, skill: skillSelected, targets: opponentTeam)

        queueAction(action)
        let results = executeNextAction()
        battleEffectsDelegate?.showUseSkill(currentGameStateEntity.id, true) { [weak self] in
            self?.updateLogAndEntityAfterSkillUse(results, currentGameStateEntity)
        }
    }

    fileprivate func updateLogAndEntityAfterSkillUse(_ results: [EffectResult], _ currentGameStateEntity: GameStateEntity) {
        for result in results {
            logMessage(result.description)
        }
        updateEntityForNewTurnAndAllEntities(currentGameStateEntity)
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

    private func executeOpponentTurn(_ entity: GameStateEntity) {
        if let aiComponent = entity.getComponent(ofType: AIComponent.self) {
            let action = aiComponent.determineAction(entity, playerTeam, opponentTeam)
            let results = action.execute()
            battleEffectsDelegate?.showUseSkill(entity.id, false) { [weak self] in
                self?.updateLogAfterMove(results)
                self?.updateEntityForNewTurnAndAllEntities(entity)
                self?.startGameLoop()
            }
        }
    }

    private func updateLogAfterMove(_ results: [EffectResult]) {
        for result in results {
            logMessage(result.description)
        }
    }

    func updateEntityForNewTurnAndAllEntities(_ entity: GameStateEntity) {
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

        updateHealthBars()
        checkIfEntitiesAreDead()
    }

    private func updateHealthBars() {
        playersPlusOpponents.forEach {
            let currentHealth = $0.getComponent(ofType: StatsComponent.self)?.currentHealth
            let maxHealth = $0.getComponent(ofType: StatsComponent.self)?.maxHealth
            guard let currentHealth = currentHealth, let maxHealth = maxHealth else { return }
            battleEffectsDelegate?.updateHealthBar($0.id, currentHealth, maxHealth)
        }
    }

    func checkIfEntitiesAreDead() {
        for entity in playersPlusOpponents {
            if entity.isDead() {
                playersPlusOpponents.removeAll { $0.id == entity.id }
                playerTeam.removeAll { $0.id == entity.id }
                opponentTeam.removeAll { $0.id == entity.id }
                battleEffectsDelegate?.removeDeadBody(entity.id)
            }
        }
    }

    private func isBattleOver() -> Bool {

        if playerTeam.isEmpty {
            logMessage("Battle ended! You lost!")
        } else if opponentTeam.isEmpty {
            logMessage("Battle ended! You won!")
        }
        return playerTeam.isEmpty || opponentTeam.isEmpty
    }

    private func logMessage(_ message: String) {
        self.battleLog.append(message)
    }

    func getCurrentTurn() -> TurnState {
        currentTurn
    }

    func getBattleLog() -> [String] {
        battleLog
    }

//    fileprivate func saveCharactersForRestart() {
//        self.savedPlayerTeam = self.playerTeam.map{ $0.copy() }
//        self.savedOpponentTeam = self.opponentTeam.map{ $0.copy() }
//        self.savedPlayersPlusOpponents = self.savedPlayerTeam + self.savedOpponentTeam
//    }

//    func restart() {
//        battleLog = []
//        playerTeam = savedPlayerTeam
//        opponentTeam = savedOpponentTeam
//        playersPlusOpponents = savedPlayersPlusOpponents
//        saveCharactersForRestart()
//        startGameLoop()
//    }
}

enum TurnState {
    case playerTurn
    case monsterTurn
}
