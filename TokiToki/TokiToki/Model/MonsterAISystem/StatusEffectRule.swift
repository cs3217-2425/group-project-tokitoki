//
//  StatusEffectRule.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class StatusEffectRule: AIRule {
    let priority: Int
    let action: Action
    let statusEffect: StatusEffectType
    let shouldApply: Bool

    init(priority: Int, action: Action, statusEffect: StatusEffectType, shouldApply: Bool) {
        self.priority = priority
        self.action = action
        self.statusEffect = statusEffect
        self.shouldApply = shouldApply
    }

    func condition(_ gameState: GameState) -> Bool {
        if let skillAction = action as? UseSkillAction {
            for targetId in skillAction.targetIds {
                if let target = gameState.getEntity(id: targetId),
                   let statusComponent = target.getComponent(ofType: StatusEffectsComponent.self) {

                    let hasEffect = statusComponent.hasEffect(ofType: statusEffect)
                    return shouldApply ? !hasEffect : hasEffect
                }
            }
        }
        return false
    }
}
