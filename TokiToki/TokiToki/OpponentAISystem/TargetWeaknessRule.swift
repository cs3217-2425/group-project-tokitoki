//
//  TargetWeaknessRule.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class TargetWeaknessRule: AIRule {
    let priority: Int
    let skillAction: UseSkillAction
    let effectivenessSystem: ElementsSystem

    init(priority: Int, action: UseSkillAction, effectivenessSystem: ElementsSystem) {
        self.priority = priority
        self.skillAction = action
        self.effectivenessSystem = effectivenessSystem
    }

    func condition(_ entity: GameStateEntity) -> Bool {
        let skillsComponent = entity.getComponent(ofType: SkillsComponent.self)
        let skill = skillsComponent?.skills.first(where: { $0.id == skillAction.skill.id })

        // Check if at least one target is weak to this skill's element
        for target in skillAction.targets {
            
            let targetStats = target.getComponent(ofType: StatsComponent.self)
           guard let targetStats = targetStats, let skill = skill else {
               return false
           }
               
            let effectiveness = effectivenessSystem.getEffectiveness(
                of: skill.elementType,
                against: targetStats.elementType
            )

            if effectiveness > 1.0 {
                return true
            }
            
        }
        
        return false
    }
}
