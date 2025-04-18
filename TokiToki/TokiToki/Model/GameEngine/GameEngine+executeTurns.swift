//
//  GameEngine+executeTurns.swift
//  TokiToki
//
//  Created by proglab on 14/4/25.
//

import Foundation

extension GameEngine {
    internal func createBattleEventAndPublishToEventBus(_ currentGameStateEntity: GameStateEntity,
                                                           _ skillSelected: any Skill,
                                                           _ targets: [GameStateEntity]) {
        battleEventManager.publishSkillUsedEvent(
            user: currentGameStateEntity,
            skill: skillSelected,
            targets: targets
        )
    }

    internal func createAndExecuteSkillAction(_ currentGameStateEntity: GameStateEntity,
                                              _ skillSelected: any Skill, _ targets: [GameStateEntity]) {
//        let context = EffectCalculationContext(globalStatusEffectsManager: globalStatusEffectsManager,
//                                               battleEffectsDelegate: battleEffectsDelegate,
//                                               reviverDelegate: self)
        let action = UseSkillAction(user: currentGameStateEntity, skill: skillSelected, playerTeam,
                                    opponentTeam, targets, effectContext)
        queueAction(action)
        let results = executeNextAction()
        battleEffectsDelegate?.showUseSkill(currentGameStateEntity.id, true) { [weak self] in
            self?.updateLogAndEntityAfterActionTaken(results, currentGameStateEntity)
        }
    }

    internal func updateLogAndEntityAfterActionTaken(_ results: [EffectResult], _ currentGameStateEntity: GameStateEntity) {
        logMultipleResults(results)
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
            battleEventManager.publishEffectResult(result, sourceId: sourceId)
        }

        return results
    }

    internal func executeOpponentTurn(_ entity: GameStateEntity) {
        battleEffectsDelegate?.showWhoseTurn(entity.id)
        if let aiComponent = entity.getComponent(ofType: AIComponent.self) {
            let action = aiComponent.determineAction(entity, playerTeam, opponentTeam, effectContext)

            let results = action.execute()

            let targets = results.compactMap { $0.entity as? GameStateEntity }

            if let skillAction = action as? UseSkillAction {
                createBattleEventAndPublishToEventBus(entity, skillAction.skill, targets)
            }

            for result in results {
                battleEventManager.publishEffectResult(result, sourceId: entity.id)
            }

            battleEffectsDelegate?.showUseSkill(entity.id, false) { [weak self] in
                self?.logMultipleResults(results)
                self?.updateEntityForNewTurnAndAllEntities(entity)
            }
        }
    }

    func updateEntityForNewTurnAndAllEntities(_ entity: GameStateEntity) {
        updateEntityForNewTurn(entity)
        updateHealthBars { [weak self] in
            self?.handleDeadBodiesInSequence()
            self?.startGameLoop()
        }
    }
    
    // Assume that this function which is only called in isolation when toki is immobilised, will not
    // activate any passives of passive equipments equipped on a toki
    internal func updateEntityForNewTurn(_ entity: GameStateEntity) {
        updateSkillCooldowns(entity)
        statusEffectsSystem.update([entity])
        statsModifiersSystem.update([entity])
        turnSystem.endTurn(for: entity)
    }

    internal func updateSkillCooldowns(_ entity: GameStateEntity) {
        skillsSystem.update([entity])
    }

    internal func updateHealthBars(completion: @escaping () -> Void = {}) {
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
    
    internal func handleDeadBodiesInSequence() {
        removeDeadBodies()
        applyPassiveEquipmentEffects()
        removeDeadEntitiesFromModel()
    }
    
    internal func removeDeadBodies() {
        for entity in playersPlusOpponents {
            if statsSystem.checkIsEntityDead(entity) {
                globalStatusEffectsManager.removeGlobalStatusEffectsOfDeadEntity(entity)
                battleEffectsDelegate?.removeDeadBody(entity.id)
            }
        }
    }
    
    internal func removeDeadEntitiesFromModel() {
        for entity in playersPlusOpponents {
            if statsSystem.checkIsEntityDead(entity) {
                playersPlusOpponents.removeAll { $0.id == entity.id }
                playerTeam.removeAll { $0.id == entity.id }
                opponentTeam.removeAll { $0.id == entity.id }
            }
        }
    }
    
    internal func applyPassiveEquipmentEffects() {
        playersPlusOpponents.forEach { entity in
            let results = equipmentSystem.applyPassiveConsumable(entity, effectContext)
            logMultipleResults(results)
        }
    }
    
    func handleRevive(_ entity: GameStateEntity) {
        if !playersPlusOpponents.contains(where: { $0.id == entity.id }) {
            playersPlusOpponents.append(entity)
        }
        if savedPlayerTeam.contains(where: { $0.id == entity.id })
            && !playerTeam.contains(where: { $0.id == entity.id }) {
            playerTeam.append(entity)
        }
        if savedOpponentTeam.contains(where: { $0.id == entity.id })
            && !opponentTeam.contains(where: { $0.id == entity.id }) {
            opponentTeam.append(entity)
        }
    }
}
