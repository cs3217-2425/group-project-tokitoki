//
//  EffectCalculators.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class HealCalculator: EffectCalculator {
    private let statsSystem = StatsSystem()
    private let healPower: Int
    
    init(healPower: Int) {
        self.healPower = healPower
    }

    func calculate(moveName: String, source: GameStateEntity, target: GameStateEntity) -> EffectResult? {
        let healAmount = (healPower + statsSystem.getHeal(source) / 2)

        statsSystem.heal(amount: healAmount, [target])

        return EffectResult(entity: target, value: healAmount,
                            description: "\(source.getName()) used \(moveName) "
                            + "to heal \(target.getName()) for \(healAmount) HP")
    }
}
