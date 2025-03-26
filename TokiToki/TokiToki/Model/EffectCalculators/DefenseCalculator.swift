//
//  DefenseCalculator.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class DefenseCalculator: EffectCalculator {
    private let statsSystem = StatsSystem()
    
    func calculate(skill: Skill, source: GameStateEntity, target: GameStateEntity) -> EffectResult {
        let defenseBoost = skill.basePower

        // Apply defense boost
        statsSystem.modifyDefense(by: defenseBoost, on: [target])

        return EffectResult(entity: target, type: .defense, value: defenseBoost,
                            description: "\(source.getName()) used \(skill.name) "
                            + "to boost \(target.getName())'s defense by \(defenseBoost)")
    }
}
