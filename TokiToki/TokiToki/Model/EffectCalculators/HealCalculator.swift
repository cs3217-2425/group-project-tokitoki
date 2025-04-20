//
//  EffectCalculators.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class HealCalculator: EffectCalculator {
    let type: EffectCalculatorType = .heal
    private let statsSystem = StatsSystem()
    private let healPower: Int

    init(healPower: Int) {
        self.healPower = healPower
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EffectCalculatorCodingKeys.self)
        healPower = try container.decode(Int.self, forKey: .healPower)
    }

    func encodeAdditionalProperties(to container: inout KeyedEncodingContainer<EffectCalculatorCodingKeys>) throws {
        try container.encode(healPower, forKey: .healPower)
    }

    func calculate(moveName: String, source: GameStateEntity, target: GameStateEntity,
                   context: EffectCalculationContext) -> EffectResult? {
        let healAmount = (healPower + statsSystem.getHeal(source) / 2)

        statsSystem.heal(amount: healAmount, [target])

        return EffectResult(entity: target, value: healAmount,
                            description: "\(source.getName()) used \(moveName) "
                            + "to heal \(target.getName()) for \(healAmount) HP")
    }

    func merge(_ effectCalculator: EffectCalculator) -> EffectCalculator {
        guard let healCalculator = effectCalculator as? HealCalculator else {
            return self
        }
        return HealCalculator(healPower: self.healPower + healCalculator.healPower)
    }
}
