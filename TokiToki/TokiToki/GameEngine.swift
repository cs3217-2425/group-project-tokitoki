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
    private let eventFactory = GameEventFactory()

    private let turnSystem = TurnSystem()
    private let skillsSystem = SkillsSystem()
    private let statusEffectsSystem = StatusEffectsSystem()

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
        turnSystem.update(playersPlusOpponents)
    }

    private func getNextReadyCharacter() -> GameStateEntity? {
        turnSystem.getNextEntityToAct(playersPlusOpponents)
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

        let targets = targetsSelected ?? opponentTeam

        // Create battle event and publish to event bus
        let skillEvent = eventFactory.createSkillUsedEvent(
            user: currentGameStateEntity,
            skill: skillSelected,
            targets: targets
        )
        EventBus.shared.post(skillEvent)

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
        let results = action.execute()

        var sourceId = UUID()
        if let skillAction = action as? UseSkillAction {
            sourceId = skillAction.user.id
        }

        // Convert results to events and post them
        for result in results {
            for battleResultEvent in result.toBattleEvents(sourceId: sourceId) {
                // Post-action damage taken, status effects, etc events are emitted
                EventBus.shared.post(battleResultEvent)
            }
        }

        return results
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
        updateSkillCooldowns(entity)

        statusEffectsSystem.update([entity], logMessage)

        turnSystem.endTurn(for: entity)

        updateHealthBars()
        checkIfEntitiesAreDead()
    }

    fileprivate func updateSkillCooldowns(_ entity: GameStateEntity) {
        skillsSystem.update([entity])
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
