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
    private var currentGameStateEntity: GameStateEntity?
    private var mostRecentSkillSelected: Skill?
    private var pendingActions: [Action] = []
    private var battleLog: [String] = [] {
        didSet {
            battleLogObserver?.update(log: battleLog)
        }
    }
    private var elementsSystem = ElementsSystem()
    private let targetSelectionFactory = TargetSelectionFactory()
    private var statusEffectStrategyFactory = StatusEffectStrategyFactory()
    private var battleLogObserver: BattleLogObserver?
    private var battleEffectsDelegate: BattleEffectsDelegate?

    static let multiplierForActionMeter: Float = 0.1
    static let MAX_ACTION_BAR: Float = 100

    private let turnSystem = TurnSystem.shared
    private let skillsSystem = SkillsSystem()
    private let statusEffectsSystem = StatusEffectsSystem.shared
    private let resetSystem = ResetSystem()
    private let statsSystem = StatsSystem()
    private let statsModifiersSystem = StatsModifiersSystem()
    private let equipmentSystem = EquipmentSystem.shared

    private var savedPlayersPlusOpponents: [GameStateEntity] = []
    private var savedPlayerTeam: [GameStateEntity] = []
    private var savedOpponentTeam: [GameStateEntity] = []

    init(playerTeam: [GameStateEntity], opponentTeam: [GameStateEntity]) {
        self.playerTeam = playerTeam
        self.opponentTeam = opponentTeam
        self.playersPlusOpponents = playerTeam + opponentTeam
        self.savedPlayerTeam = playerTeam
        self.savedOpponentTeam = opponentTeam
        self.savedPlayersPlusOpponents = self.playersPlusOpponents
        self.statusEffectsSystem.setGameEngine(self)
        self.equipmentSystem.saveEquipments()
    }

    func startBattle() {
        logMessage("Battle started!")
        startGameLoop()
    }

    func addObserver(_ battleLogObserver: BattleLogObserver) {
        self.battleLogObserver = battleLogObserver
    }

    func addDelegate(_ battleEffectsDelegate: BattleEffectsDelegate) {
        self.battleEffectsDelegate = battleEffectsDelegate
    }

    func startGameLoop() {
        while !isBattleOver() {
            statusEffectsSystem.applyDmgOverTimeStatusEffects(logMessage, battleEffectsDelegate)
            currentGameStateEntity = getNextReadyCharacter()

            guard let currentGameStateEntity = currentGameStateEntity else {
                updateAllActionMeters()
                continue
            }

            if statusEffectsSystem.checkIfImmobilised(currentGameStateEntity) {
                updateEntityForNewTurn(currentGameStateEntity)
                continue
            }

            if (opponentTeam.contains { $0.id == currentGameStateEntity.id }) {
                executeOpponentTurn(currentGameStateEntity)
                return
            }

            logMessage("It's now \(currentGameStateEntity.name)'s turn!")
            updateSkillIconsForCurrentEntity(currentGameStateEntity)
            return
        }
    }

    private func updateAllActionMeters() {
        turnSystem.update(playersPlusOpponents)
        statusEffectsSystem.updateDmgOverTimeEffectsActionMeter()
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

    func useTokiSkill(_ skillIndex: Int) {
        guard let currentGameStateEntity = currentGameStateEntity else {
            return
        }
        let skillSelected = currentGameStateEntity.getComponent(ofType: SkillsComponent.self)?.skills[skillIndex]
        guard let skillSelected = skillSelected else {
            return
        }
        mostRecentSkillSelected = skillSelected

        let singleTargetEffect = skillSelected.effectDefinitions.first {
            targetSelectionFactory.checkIfRequireTargetSelection($0.targetType)
        }

        if let singleTargetEffect = singleTargetEffect {
            if singleTargetEffect.targetType == .singleEnemy && opponentTeam.count > 1 {
                battleEffectsDelegate?.allowOpponentTargetSelection()
                logMessage("Choose a target")
                return
            }

            if singleTargetEffect.targetType == .singleAlly && playerTeam.count > 1 {
                battleEffectsDelegate?.allowAllyTargetSelection()
                logMessage("Choose a target")
                return
            }
        }

        // TODO: update event bus with new changes
        let targets = targetSelectionFactory.generateTargets(currentGameStateEntity, playerTeam, opponentTeam,
                                                             skillSelected.effectDefinitions[0].targetType)
        createBattleEventAndPublishToEventBus(currentGameStateEntity, skillSelected, targets)

        createAndExecuteSkillAction(currentGameStateEntity, skillSelected, [])
    }

    func useSingleTargetTokiSkill(_ targetId: UUID) {
        let target = playersPlusOpponents.first { $0.id == targetId }
        guard let mostRecentSkillSelected = mostRecentSkillSelected,
        let currentGameStateEntity = currentGameStateEntity,
        let target = target else {
            return
        }
        createBattleEventAndPublishToEventBus(currentGameStateEntity, mostRecentSkillSelected, [target])
        createAndExecuteSkillAction(currentGameStateEntity, mostRecentSkillSelected, [target])
    }

    func useConsumable(_ consumableName: String) {
        let consumable = equipmentSystem.getConsumable(consumableName)
        guard let currentGameStateEntity = currentGameStateEntity,
              let consumable = consumable as? ConsumableEquipment else {
            return
        }
        let action = UseConsumableAction(user: currentGameStateEntity, consumable: consumable)
        queueAction(action)
        let results = executeNextAction()
        battleEffectsDelegate?.showUseSkill(currentGameStateEntity.id, true) { [weak self] in
            self?.updateLogAndEntityAfterActionTaken(results, currentGameStateEntity)
        }
    }

    func takeNoAction() {
        guard let currentGameStateEntity = currentGameStateEntity else {
            return
        }
        let action = NoAction(entity: currentGameStateEntity)
        queueAction(action)
        let results = executeNextAction()
        updateLogAndEntityAfterActionTaken(results, currentGameStateEntity)
    }

    fileprivate func createBattleEventAndPublishToEventBus(_ currentGameStateEntity: GameStateEntity,
                                                           _ skillSelected: any Skill,
                                                           _ targets: [GameStateEntity]) {
        BattleEventManager.shared.publishSkillUsedEvent(
            user: currentGameStateEntity,
            skill: skillSelected,
            targets: targets
        )
    }

    private func createAndExecuteSkillAction(_ currentGameStateEntity: GameStateEntity,
                                             _ skillSelected: any Skill, _ targets: [GameStateEntity]) {
        let action = UseSkillAction(user: currentGameStateEntity, skill: skillSelected, playerTeam,
                                    opponentTeam, targets)
        queueAction(action)
        let results = executeNextAction()
        battleEffectsDelegate?.showUseSkill(currentGameStateEntity.id, true) { [weak self] in
            self?.updateLogAndEntityAfterActionTaken(results, currentGameStateEntity)
        }
    }

    fileprivate func updateLogAndEntityAfterActionTaken(_ results: [EffectResult], _ currentGameStateEntity: GameStateEntity) {
        for result in results {
            logMessage(result.description)
        }
        updateEntityForNewTurnAndAllEntities(currentGameStateEntity)
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

        for result in results {
            BattleEventManager.shared.publishEffectResult(result, sourceId: sourceId)
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
        statsModifiersSystem.update([entity])
        turnSystem.endTurn(for: entity)
        updateHealthBars { [weak self] in
            self?.checkIfEntitiesAreDead()
            self?.startGameLoop()
        }
    }

    private func updateEntityForNewTurn(_ entity: GameStateEntity) {
        updateSkillCooldowns(entity)
        statusEffectsSystem.update([entity], logMessage)
        statsModifiersSystem.update([entity])
        turnSystem.endTurn(for: entity)
    }

    fileprivate func updateSkillCooldowns(_ entity: GameStateEntity) {
        skillsSystem.update([entity])
    }

    private func updateHealthBars(completion: @escaping () -> Void = {}) {
        var remainingAnimations = playersPlusOpponents.count

        playersPlusOpponents.forEach {
            let currentHealth = $0.getComponent(ofType: StatsComponent.self)?.currentHealth
            let maxHealth = $0.getComponent(ofType: StatsComponent.self)?.baseStats.hp
            guard let currentHealth = currentHealth, let maxHealth = maxHealth else { return }
            battleEffectsDelegate?.updateHealthBar($0.id, currentHealth, maxHealth) {
                remainingAnimations -= 1

                if remainingAnimations == 0 {
                    completion()
                }
            }
        }
    }

    func checkIfEntitiesAreDead() {
        for entity in playersPlusOpponents {
            if statsSystem.checkIsEntityDead(entity) {
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
        if message == "" {
            return
        }
        self.battleLog.append(message)
    }

    func getBattleLog() -> [String] {
        battleLog
    }

    func restart() {
        battleLog = []
        resetSystem.reset(savedPlayersPlusOpponents)
        playersPlusOpponents = savedPlayersPlusOpponents
        playerTeam = savedPlayerTeam
        opponentTeam = savedOpponentTeam
        mostRecentSkillSelected = nil
        pendingActions = []
        updateHealthBars()
        startBattle()
    }
}
