//
//  StatsModfiersCalculator.swift
//  TokiToki
//
//  Created by proglab on 2/4/25.
//

class StatsModifiersCalculator: EffectCalculator {
    let type: EffectCalculatorType = .statsModifiers
    private let statsSystem = StatsSystem()
    let statsModifiers: [StatsModifier]

    init(statsModifiers: [StatsModifier] = []) {
        self.statsModifiers = statsModifiers
    }

    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: EffectCalculatorCodingKeys.self)
            statsModifiers = try container.decode([StatsModifier].self, forKey: .statsModifiers)
        }

        func encodeAdditionalProperties(to container: inout KeyedEncodingContainer<EffectCalculatorCodingKeys>) throws {
            try container.encode(statsModifiers, forKey: .statsModifiers)
        }

    func calculate(moveName: String, source: GameStateEntity, target: GameStateEntity,
                   context: EffectCalculationContext) -> EffectResult? {
        for modifier in statsModifiers {
            guard let statsModifiersComponent = target.getComponent(ofType: StatsModifiersComponent.self) else {
                return nil
            }
            StatsModifiersSystem().addModifier(modifier, target)
            return EffectResult(entity: target, value: 0,
                                        description: modifier.describeChanges(for: target))
        }
        return nil
    }
}
