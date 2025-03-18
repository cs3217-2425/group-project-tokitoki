//
//  EffectCalculatorFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class EffectCalculatorFactory {
    private let calculators: [SkillType: EffectCalculator] = [
        .attack: AttackCalculator(),
        .heal: HealCalculator(),
        .defend: DefenseCalculator(),
        .buff: BuffCalculator(),
        .debuff: DebuffCalculator()
    ]

    func getCalculator(for skillType: SkillType) -> EffectCalculator {
        calculators[skillType] ?? AttackCalculator() // Default to attack if not found
    }
}
