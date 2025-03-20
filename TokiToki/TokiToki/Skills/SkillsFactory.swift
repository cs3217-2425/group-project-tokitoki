//
//  SkillsFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class SkillFactory {
    private let effectCalculatorFactory = EffectCalculatorFactory()


    func createAttackSkill(name: String, description: String, elementType: ElementType, basePower: Int,
                           cooldown: Int, targetType: TargetType, statusEffect: StatusEffectType? = nil,
                           statusEffectChance: Double = 0.0, statusEffectDuration: Int = 0) -> Skill {
        let calculator = effectCalculatorFactory.getCalculator(for: .attack)

        return BaseSkill(
            name: name,
            description: description,
            type: .attack,
            targetType: targetType,
            elementType: elementType,
            basePower: basePower,
            cooldown: cooldown,
            statusEffectChance: statusEffectChance,
            statusEffect: statusEffect,
            statusEffectDuration: statusEffectDuration,
            effectCalculator: calculator
        )
    }

    func createHealSkill(name: String, description: String, basePower: Int, cooldown: Int, targetType: TargetType) -> Skill {
        let calculator = effectCalculatorFactory.getCalculator(for: .heal)

        return BaseSkill(
            name: name,
            description: description,
            type: .heal,
            targetType: targetType,
            elementType: .neutral,
            basePower: basePower,
            cooldown: cooldown,
            statusEffectChance: 0.0,
            statusEffect: nil,
            statusEffectDuration: 0,
            effectCalculator: calculator
        )
    }

    func createDefenseSkill(name: String, description: String, basePower: Int, cooldown: Int, targetType: TargetType) -> Skill {
        let calculator = effectCalculatorFactory.getCalculator(for: .defend)

        return BaseSkill(
            name: name,
            description: description,
            type: .defend,
            targetType: targetType,
            elementType: .neutral,
            basePower: basePower,
            cooldown: cooldown,
            statusEffectChance: 0.0,
            statusEffect: nil,
            statusEffectDuration: 0,
            effectCalculator: calculator
        )
    }

    func createBuffSkill(name: String, description: String, basePower: Int, cooldown: Int,
                         targetType: TargetType, statusEffect: StatusEffectType, duration: Int) -> Skill {
        let calculator = effectCalculatorFactory.getCalculator(for: .buff)

        return BaseSkill(
            name: name,
            description: description,
            type: .buff,
            targetType: targetType,
            elementType: .neutral,
            basePower: basePower,
            cooldown: cooldown,
            statusEffectChance: 1.0,
            statusEffect: statusEffect,
            statusEffectDuration: duration,
            effectCalculator: calculator
        )
    }

    func createDebuffSkill(name: String, description: String, basePower: Int, cooldown: Int,
                           targetType: TargetType, statusEffect: StatusEffectType, duration: Int) -> Skill {
        let calculator = effectCalculatorFactory.getCalculator(for: .debuff)

        return BaseSkill(
            name: name,
            description: description,
            type: .debuff,
            targetType: targetType,
            elementType: .neutral,
            basePower: basePower,
            cooldown: cooldown,
            statusEffectChance: 1.0,
            statusEffect: statusEffect,
            statusEffectDuration: duration,
            effectCalculator: calculator
        )
    }
}
