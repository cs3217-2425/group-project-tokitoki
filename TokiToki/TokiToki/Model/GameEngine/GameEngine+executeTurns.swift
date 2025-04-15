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
        BattleEventManager.shared.publishSkillUsedEvent(
            user: currentGameStateEntity,
            skill: skillSelected,
            targets: targets
        )
    }

    internal func createAndExecuteSkillAction(_ currentGameStateEntity: GameStateEntity,
                                             _ skillSelected: any Skill, _ targets: [GameStateEntity]) {
        let action = UseSkillAction(user: currentGameStateEntity, skill: skillSelected, playerTeam,
                                    opponentTeam, targets, globalStatusEffectsManager)
        queueAction(action)
        let results = executeNextAction()
        battleEffectsDelegate?.showUseSkill(currentGameStateEntity.id, true) { [weak self] in
            self?.updateLogAndEntityAfterActionTaken(results, currentGameStateEntity)
        }
    }

    internal func updateLogAndEntityAfterActionTaken(_ results: [EffectResult], _ currentGameStateEntity: GameStateEntity) {
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

    internal func executeOpponentTurn(_ entity: GameStateEntity) {
        if let aiComponent = entity.getComponent(ofType: AIComponent.self) {
            let action = aiComponent.determineAction(entity, playerTeam, opponentTeam, globalStatusEffectsManager)
            let results = action.execute()

            battleEffectsDelegate?.showUseSkill(entity.id, false) { [weak self] in
                for result in results {
                    BattleEventManager.shared.publishEffectResult(result, sourceId: self?.currentGameStateEntity?.id ?? UUID())
                }
                self?.updateLogAfterMove(results)
                self?.updateEntityForNewTurnAndAllEntities(entity)
            }
        }
    }

    internal func updateLogAfterMove(_ results: [EffectResult]) {
        for result in results {
            logMessage(result.description)
        }
    }

    func updateEntityForNewTurnAndAllEntities(_ entity: GameStateEntity) {
        updateEntityForNewTurn(entity)
        updateHealthBars { [weak self] in
            self?.checkIfEntitiesAreDead()
            self?.startGameLoop()
        }
    }

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
}
