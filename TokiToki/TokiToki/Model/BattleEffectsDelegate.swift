//
//  BattleEffectsDelegate.swift
//  TokiToki
//
//  Created by proglab on 20/3/25.
//

import Foundation

protocol BattleEffectsDelegate {
    func showUseSkill(_ id: UUID, _ isLeft: Bool, completion: @escaping () -> Void)
    func updateSkillIcons(_ icons: [SkillUiInfo]?)
    func updateHealthBar(_ id: UUID, _ currentHealth: Int, _ maxHealth: Int,
                         completion: @escaping () -> Void)
    func removeDeadBody(_ id: UUID)
    func allowOpponentTargetSelection()
    func allowAllyTargetSelection()
}
