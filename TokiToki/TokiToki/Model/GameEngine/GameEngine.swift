//
//  temp.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class GameEngine: StatusEffectApplierAndPublisherDelegate, ReviverDelegate {
    internal var playerTeam: [GameStateEntity]
    internal var opponentTeam: [GameStateEntity]
    internal var playersPlusOpponents: [GameStateEntity] = []
    internal var currentGameStateEntity: GameStateEntity?
    internal var mostRecentSkillSelected: Skill?
    internal var pendingActions: [Action] = []
    internal var elementsSystem = ElementsSystem()
    internal let targetSelectionFactory = TargetSelectionFactory()
    internal var statusEffectStrategyFactory = StatusEffectStrategyFactory()
    internal var battleEffectsDelegate: BattleEffectsDelegate?
    internal var battleEventManager = BattleEventManager()
    private let logManager = BattleLogManager()
    var battleLogObserver: BattleLogObserver? {
        didSet {
            logManager.observer = battleLogObserver
        }
    }
    internal var levelManager: LevelManager

    internal let MAX_ACTION_BAR: Float = 100
    internal let MULTIPLIER_FOR_ACTION_METER: Float = 0.1

    internal let playerEquipmentComponent = PlayerManager.shared.getEquipmentComponent()
    internal var globalStatusEffectsManager: GlobalStatusEffectsManaging
    internal var effectContext = EffectCalculationContext()

    internal var systems: [System] = []
    internal let statsSystem = StatsSystem()
    internal let turnSystem: TurnSystem
    internal let skillsSystem = SkillsSystem()
    internal let statusEffectsSystem = StatusEffectsSystem()
    internal let statsModifiersSystem = StatsModifiersSystem()
    internal let equipmentSystem = EquipmentSystem()
    internal let aiSystem = AiSystem()

    internal var savedPlayersPlusOpponents: [GameStateEntity] = []
    internal var savedPlayerTeam: [GameStateEntity] = []
    internal var savedOpponentTeam: [GameStateEntity] = []
    internal var savedEquipments: [Equipment] = []

    init(playerTeam: [GameStateEntity], opponentTeam: [GameStateEntity], levelManager: LevelManager) {
        self.playerTeam = playerTeam
        self.opponentTeam = opponentTeam
        self.playersPlusOpponents = playerTeam + opponentTeam
        self.savedPlayerTeam = playerTeam
        self.savedOpponentTeam = opponentTeam
        self.savedPlayersPlusOpponents = self.playersPlusOpponents
        self.turnSystem = TurnSystem(statsSystem, MAX_ACTION_BAR, MULTIPLIER_FOR_ACTION_METER)
        self.levelManager = levelManager
        
        self.globalStatusEffectsManager = GlobalStatusEffectsManager(statusEffectsSystem, MAX_ACTION_BAR,
                                                                     MULTIPLIER_FOR_ACTION_METER)
        self.effectContext = EffectCalculationContext(globalStatusEffectsManager: globalStatusEffectsManager,
                                                      battleEffectsDelegate: battleEffectsDelegate,
                                                      reviverDelegate: self,
                                                      allOpponentEntities: savedOpponentTeam)
        self.globalStatusEffectsManager.setDelegate(self)
        self.statusEffectsSystem.setDelegate(self)
        
        appendToSystemsForResetting()
        saveEquipments()
    }

    fileprivate func appendToSystemsForResetting() {
        systems.append(skillsSystem)
        systems.append(statsSystem)
        systems.append(statusEffectsSystem)
        systems.append(statsModifiersSystem)
        systems.append(turnSystem)
        systems.append(equipmentSystem)
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
        self.effectContext = EffectCalculationContext(globalStatusEffectsManager: globalStatusEffectsManager,
                                                      battleEffectsDelegate: self.battleEffectsDelegate,
                                                      reviverDelegate: self,
                                                      allOpponentEntities: savedOpponentTeam)
    }

    internal func saveEquipments() {
        self.savedEquipments = playerEquipmentComponent.inventory
    }

    func applyStatusEffectAndPublishResult(_ effect: StatusEffect, _ entity: GameStateEntity) -> Bool {
        let results = effect.apply(to: entity, strategyFactory: statusEffectStrategyFactory)
        for result in results {
            logMessage(result.description)
            battleEventManager.publishEffectResult(result, sourceId: effect.sourceId)
        }
        battleEffectsDelegate?.updateHealthBar(entity.id, statsSystem.getCurrentHealth(entity),
                                               statsSystem.getMaxHealth(entity)) { [weak self] in
            self?.handleDeadBodiesInSequence()
            
        }
        return isBattleOver()
    }

    fileprivate func addExpAndGold(_ exp: Int, _ gold: Int) {
        savedPlayerTeam.forEach {
            $0.toki.baseStats.exp += exp
        }
        PlayerManager.shared.updateAfterBattle(exp: exp, gold: gold, isWin: true)
    }
    
    internal func isBattleOver() -> Bool {
        if playerTeam.isEmpty || opponentTeam.isEmpty {
            let isWin = opponentTeam.isEmpty
            let exp = levelManager.getExp()
            let gold = levelManager.getGold()
            if isWin {
                addExpAndGold(exp, gold)
            } else {
                PlayerManager.shared.updateBattleStatistics(isWin: false)
            }
            logMessage("Battle ended! You \(isWin ? "won" : "lost")!")
            battleEventManager.publishBattleEndedEvents(isWin: isWin, exp: exp, gold: gold)
            return true
        }
        return false
    }

    internal func logMessage(_ message: String) {
        logManager.addLogMessage(message)
    }

    internal func logMultipleResults(_ results: [EffectResult]) {
        for result in results {
            logMessage(result.description)
        }
    }
    
    func countConsumables() -> [ConsumableGroupings] {
        guard let currentGameStateEntity = currentGameStateEntity else {
            return []
        }
        return equipmentSystem.countConsumables(currentGameStateEntity)
    }

    func getBattleLog() -> [String] {
        logManager.getLogMessages()
    }

    func restart() {
        logManager.clearLogs()
        resetAll()
        globalStatusEffectsManager.reset()
        playersPlusOpponents = savedPlayersPlusOpponents
        playerTeam = savedPlayerTeam
        opponentTeam = savedOpponentTeam
        playerEquipmentComponent.inventory = savedEquipments
        mostRecentSkillSelected = nil
        pendingActions = []
        updateHealthBars()
        startBattle()
    }

    fileprivate func resetAll() {
        for system in systems {
            system.reset(savedPlayersPlusOpponents)
        }
    }
}
