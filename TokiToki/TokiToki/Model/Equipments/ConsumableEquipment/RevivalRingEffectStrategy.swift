//
//  RevivalRingEffectStrategy.swift
//  TokiToki
//
//  Created by proglab on 15/4/25.
//

struct RevivalRingEffectStrategy: ConsumableEffectStrategy {
    let effectCalculators: [EffectCalculator]
    let statsSystem = StatsSystem()

    func applyEffect(name: String, to toki: Toki?, orTo entity: GameStateEntity?,
                     _ context: EffectCalculationContext,
                     completion: (() -> Void)? = nil)
    -> [EffectResult]? {
        guard let entity = entity else {
            return nil
        }
        if statsSystem.getCurrentHealth(entity) > 0 {
            return nil
        }
        var results: [EffectResult] = []
        for effectCalculator in effectCalculators {
            let result = effectCalculator.calculate(moveName: name,
                                                    source: entity, target: entity,
                                                    context: context)
            guard let result = result else {
                continue
            }
            results.append(result)
        }
        completion?()
        return results
    }
}
