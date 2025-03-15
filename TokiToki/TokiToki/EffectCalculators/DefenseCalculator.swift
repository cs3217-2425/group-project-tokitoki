//
//  DefenseCalculator.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class DefenseCalculator: EffectCalculator {
    func calculate(skill: Skill, source: Entity, target: Entity) -> EffectResult {
        let defenseBoost = skill.basePower

        // Apply defense boost
        target.modifyDefense(by: defenseBoost)

        return EffectResult(entity: target, type: .defense, value: defenseBoost,
                            description: "\(source.getName()) used \(skill.name) "
                            + "to boost \(target.getName())'s defense by \(defenseBoost)")
    }
}
