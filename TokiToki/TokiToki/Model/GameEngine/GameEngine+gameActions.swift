//
//  GameEngine+gameActions.swift
//  TokiToki
//
//  Created by proglab on 14/4/25.
//

import Foundation

extension GameEngine {
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
        guard let currentGameStateEntity = currentGameStateEntity,
              let equipmentComponent = currentGameStateEntity.getComponent(ofType: EquipmentComponent.self) else {
            return
        }
        
        let consumable = equipmentComponent.inventory.first { $0.equipmentType == .consumable && $0.name == consumableName }
        guard let consumable = consumable as? ConsumableEquipment else {
            return
        }
        let action = UseConsumableAction(user: currentGameStateEntity, consumable: consumable, equipmentSystem,
                                         effectContext)
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
}
