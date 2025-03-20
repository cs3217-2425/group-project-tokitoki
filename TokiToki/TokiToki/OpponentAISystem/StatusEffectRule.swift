//
//  StatusEffectRule.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class StatusEffectRule: AIRule {
    let priority: Int
    let skillAction: UseSkillAction
    let statusEffect: StatusEffectType
    let shouldApply: Bool

    init(priority: Int, action: UseSkillAction, statusEffect: StatusEffectType, shouldApply: Bool) {
        self.priority = priority
        self.skillAction = action
        self.statusEffect = statusEffect
        self.shouldApply = shouldApply
    }

    func condition(_ entity: GameStateEntity) -> Bool {

        for target in skillAction.targets {
            let statusComponent = target.getComponent(ofType: StatusEffectsComponent.self)
            guard let statusComponent = statusComponent else {
                return false
            }
            let hasEffect = statusComponent.hasEffect(ofType: statusEffect)
            return shouldApply ? !hasEffect : hasEffect
        }

        return false
    }

}
