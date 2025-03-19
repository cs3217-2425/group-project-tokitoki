//
//  TargetWeaknessRule.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class TargetWeaknessRule: AIRule {
    let priority: Int
    let action: Action
    let effectivenessSystem: ElementEffectivenessSystem

    init(priority: Int, action: Action, effectivenessSystem: ElementEffectivenessSystem) {
        self.priority = priority
        self.action = action
        self.effectivenessSystem = effectivenessSystem
    }

    func condition(_ gameState: TurnManager) -> Bool {
        if let skillAction = action as? UseSkillAction,
           let source = gameState.getEntity(id: skillAction.user),
           let skillsComponent = source.getComponent(ofType: SkillsComponent.self),
           let skill = skillsComponent.skills.first(where: { $0.id == skillAction.skillId }) {

            // Check if at least one target is weak to this skill's element
            for targetId in skillAction.targets {
                if let target = gameState.getEntity(id: targetId),
                   let targetStats = target.getComponent(ofType: StatsComponent.self) {

                    let effectiveness = effectivenessSystem.getEffectiveness(
                        of: skill.elementType,
                        against: targetStats.elementType
                    )

                    if effectiveness > 1.0 {
                        return true
                    }
                }
            }
        }
        return false
    }
}
