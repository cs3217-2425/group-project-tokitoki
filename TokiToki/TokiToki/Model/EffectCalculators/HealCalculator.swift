//
//  EffectCalculators.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class HealCalculator: EffectCalculator {
    private let statsSystem = StatsSystem()
    
    func calculate(skill: Skill, source: GameStateEntity, target: GameStateEntity) -> EffectResult {
        guard let sourceStats = source.getComponent(ofType: StatsComponent.self) else {
            return EffectResult(entity: target, type: .none, value: 0, description: "Failed to get stats")
        }

        // Base formula for healing - based on skill power and a percentage of the user's attack
        let healAmount = (skill.basePower + sourceStats.attack / 2)

        // Apply healing
        statsSystem.heal(amount: healAmount, [target])

        return EffectResult(entity: target, type: .heal, value: healAmount,
                            description: "\(source.getName()) used \(skill.name) "
                            + "to heal \(target.getName()) for \(healAmount) HP")
    }
}
