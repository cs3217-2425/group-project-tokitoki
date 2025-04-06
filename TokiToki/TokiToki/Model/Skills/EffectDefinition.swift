//
//  EffectDefinition.swift
//  TokiToki
//
//  Created by proglab on 2/4/25.
//

class EffectDefinition {
    let targetType: TargetType
    let effectCalculators: [EffectCalculator]

    init(targetType: TargetType, effectCalculators: [EffectCalculator]) {
        self.targetType = targetType
        self.effectCalculators = effectCalculators
    }
}
