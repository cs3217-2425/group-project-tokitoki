//
//  consumableToEffectStrategy.swift
//  TokiToki
//
//  Created by proglab on 18/4/25.
//

let consumableToEffectStrategy: [String: ConsumableEffectStrategy] = [
    "potion": PotionEffectStrategy(effectCalculators: [HealCalculator(healPower: 100)]),
    "revivalRing": RevivalRingEffectStrategy(effectCalculators: [ReviveCalculator(revivePower: 1.0)])
]
