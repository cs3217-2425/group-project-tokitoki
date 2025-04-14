//
//  temp.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class GameEngine: StatusEffectApplierAndPublisherDelegate {
    internal var playerTeam: [GameStateEntity]
    internal var opponentTeam: [GameStateEntity]
    internal var playersPlusOpponents: [GameStateEntity] = []
    internal var currentGameStateEntity: GameStateEntity?
    internal var mostRecentSkillSelected: Skill?
    internal var pendingActions: [Action] = []
    internal var battleLog: [String] = [] {
        didSet {
            battleLogObserver?.update(log: battleLog)
        }
    }
    internal var elementsSystem = ElementsSystem()
    internal let targetSelectionFactory = TargetSelectionFactory()
    internal var statusEffectStrategyFactory = StatusEffectStrategyFactory()
    internal var battleLogObserver: BattleLogObserver?
    internal var battleEffectsDelegate: BattleEffectsDelegate?

    internal let MAX_ACTION_BAR: Float = 100
    internal let MULTIPLIER_FOR_ACTION_METER: Float = 0.1

    internal let playerEquipmentComponent = PlayerManager.shared.getEquipmentComponent()
    internal var globalStatusEffectsManager: GlobalStatusEffectsManaging

    internal var systems: [System] = []
    internal let statsSystem = StatsSystem()
    internal let turnSystem: TurnSystem
    internal let skillsSystem = SkillsSystem()
    internal let statusEffectsSystem = StatusEffectsSystem()
    internal let statsModifiersSystem = StatsModifiersSystem()
    internal let equipmentSystem = EquipmentSystem()

    internal var savedPlayersPlusOpponents: [GameStateEntity] = []
    internal var savedPlayerTeam: [GameStateEntity] = []
    internal var savedOpponentTeam: [GameStateEntity] = []
    internal var savedEquipments: [Equipment] = []

    init(playerTeam: [GameStateEntity], opponentTeam: [GameStateEntity]) {
        self.playerTeam = playerTeam
        self.opponentTeam = opponentTeam
        self.playersPlusOpponents = playerTeam + opponentTeam
        self.savedPlayerTeam = playerTeam
        self.savedOpponentTeam = opponentTeam
        self.savedPlayersPlusOpponents = self.playersPlusOpponents
        self.turnSystem = TurnSystem(statsSystem, MAX_ACTION_BAR, MULTIPLIER_FOR_ACTION_METER)
        
        self.globalStatusEffectsManager = GlobalStatusEffectsManager(statusEffectsSystem, MAX_ACTION_BAR,
                                                                     MULTIPLIER_FOR_ACTION_METER)
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

    internal func saveEquipments() {
        self.savedEquipments = playerEquipmentComponent.inventory
    }
    
    func applyStatusEffectAndPublishResult(_ effect: StatusEffect, _ entity: GameStateEntity) {
        let result = effect.apply(to: entity, strategyFactory: statusEffectStrategyFactory)
        logMessage(result.description)
        battleEffectsDelegate?.updateHealthBar(entity.id, statsSystem.getCurrentHealth(entity),
                                               statsSystem.getMaxHealth(entity)) { [weak self] in
            self?.checkIfEntitiesAreDead()
        }

        BattleEventManager.shared.publishEffectResult(result, sourceId: effect.sourceId)
    }

    func checkIfEntitiesAreDead() {
        for entity in playersPlusOpponents {
            if statsSystem.checkIsEntityDead(entity) {
                globalStatusEffectsManager.removeGlobalStatusEffectsOfDeadEntity(entity)
                playersPlusOpponents.removeAll { $0.id == entity.id }
                playerTeam.removeAll { $0.id == entity.id }
                opponentTeam.removeAll { $0.id == entity.id }
                battleEffectsDelegate?.removeDeadBody(entity.id)
            }
        }
    }

    internal func isBattleOver() -> Bool {
        if playerTeam.isEmpty {
            logMessage("Battle ended! You lost!")
        } else if opponentTeam.isEmpty {
            logMessage("Battle ended! You won!")
        }
        return playerTeam.isEmpty || opponentTeam.isEmpty
    }

    internal func logMessage(_ message: String) {
        if message.isEmpty {
            return
        }
        self.battleLog.append(message)
    }

    func getBattleLog() -> [String] {
        battleLog
    }

    func restart() {
        battleLog = []
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
