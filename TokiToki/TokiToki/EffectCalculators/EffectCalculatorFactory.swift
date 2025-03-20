//
//  EffectCalculatorFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class EffectCalculatorFactory {
    private let elementsSystem: ElementsSystem = ElementsSystem()
    private let calculators: [SkillType: EffectCalculator]

    init() {
        self.calculators = [
           .attack: AttackCalculator(elementsSystem: elementsSystem),
           .heal: HealCalculator(),
           .defend: DefenseCalculator(),
           .buff: BuffCalculator(),
           .debuff: DebuffCalculator()
       ]
    }

    func getCalculator(for skillType: SkillType) -> EffectCalculator {
        calculators[skillType] ?? AttackCalculator(elementsSystem: self.elementsSystem) // Default to attack if not found
    }
}
