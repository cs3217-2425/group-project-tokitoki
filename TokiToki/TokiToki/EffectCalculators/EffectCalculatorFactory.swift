//
//  EffectCalculatorFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class EffectCalculatorFactory {
    private let elementEffectivenessSystem: ElementEffectivenessSystem
    private let calculators: [SkillType: EffectCalculator]

    init(elementEffectivenessSystem: ElementEffectivenessSystem) {
        self.elementEffectivenessSystem = elementEffectivenessSystem
        self.calculators = [
           .attack: AttackCalculator(elementEffectivenessSystem: elementEffectivenessSystem),
           .heal: HealCalculator(),
           .defend: DefenseCalculator(),
           .buff: BuffCalculator(),
           .debuff: DebuffCalculator()
       ]
    }

    func getCalculator(for skillType: SkillType) -> EffectCalculator {
        calculators[skillType] ?? AttackCalculator(elementEffectivenessSystem: self.elementEffectivenessSystem) // Default to attack if not found
    }
}
