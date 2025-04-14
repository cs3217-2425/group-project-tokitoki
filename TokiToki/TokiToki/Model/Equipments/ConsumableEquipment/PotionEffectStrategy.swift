//
//  PotionEffectStrategy.swift
//  TokiToki
//
//  Created by proglab on 11/4/25.
//

struct PotionEffectStrategy: ConsumableEffectStrategy {
    let effectCalculators: [EffectCalculator]

    func applyEffect(name: String, to toki: Toki?, orTo entity: GameStateEntity?,
                     _ globalStatusEffectsManager: GlobalStatusEffectsManaging?,
                     completion: (() -> Void)? = nil)
    -> [EffectResult]? {
        guard let entity = entity else {
            return nil
        }
        var results: [EffectResult] = []
        for effectCalculator in effectCalculators {
            let result = effectCalculator.calculate(moveName: name,
                                                    source: entity, target: entity,
                                                    context: EffectCalculationContext(
                                                        globalStatusEffectsManager: globalStatusEffectsManager))
            guard let result = result else {
                continue
            }
            results.append(result)
        }
        completion?()
        return results
    }
}
