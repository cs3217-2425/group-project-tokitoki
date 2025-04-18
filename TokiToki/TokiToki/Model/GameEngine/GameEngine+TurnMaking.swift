//
//  GameEngine+TurnMaking.swift
//  TokiToki
//
//  Created by proglab on 14/4/25.
//

extension GameEngine {
    func startGameLoop() {
        while !isBattleOver() {
            let isBattleOver = globalStatusEffectsManager
                .applyGlobalStatusEffectsAndCheckIsBattleOver(playersPlusOpponents)
            if isBattleOver {
                return
            }
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

    internal func updateAllActionMeters() {
        turnSystem.update(playersPlusOpponents)
        globalStatusEffectsManager.updateGlobalStatusEffectsActionMeter()
    }

    internal func getNextReadyCharacter() -> GameStateEntity? {
        turnSystem.getNextEntityToAct(playersPlusOpponents)
    }

    internal func updateSkillIconsForCurrentEntity(_ currentGameStateEntity: GameStateEntity) {
        let skillsAvailable = currentGameStateEntity.getComponent(ofType: SkillsComponent.self)?.skills
        let skillIcons = skillsAvailable?.map { skill in
            let skillIcon = skillsToIconImage[skill.name]
            guard let skillIcon = skillIcon else {
                return SkillUiInfo(iconImgString: "", cooldown: skill.currentCooldown)
            }
            return SkillUiInfo(iconImgString: skillIcon, cooldown: skill.currentCooldown)
        }
        battleEffectsDelegate?.updateSkillIcons(skillIcons)
        battleEffectsDelegate?.showWhoseTurn(currentGameStateEntity.id)
    }
}
