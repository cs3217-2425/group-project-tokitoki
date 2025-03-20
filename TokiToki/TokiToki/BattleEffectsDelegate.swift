//
//  BattleEffectsDelegate.swift
//  TokiToki
//
//  Created by proglab on 20/3/25.
//

import Foundation

protocol BattleEffectsDelegate {
    func showUseSkill(_ id: UUID, completion: @escaping () -> Void)
    func updateSkillIcons(_ icons: [String]?)
}
