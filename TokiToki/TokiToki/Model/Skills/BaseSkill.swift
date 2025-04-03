//
//  BaseSkill.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class BaseSkill: Skill {
    let id = UUID()
    let name: String
    let description: String
    let type: SkillType
    let targetType: TargetType
    let elementType: ElementType
    let basePower: Int
    let cooldown: Int
    var currentCooldown: Int = 0
    let statusEffectChance: Double
    let statusEffect: StatusEffectType?
    let statusEffectDuration: Int
    let rarity: ItemRarity

    private let effectCalculator: EffectCalculator

    init(name: String, description: String, type: SkillType, targetType: TargetType,
         elementType: ElementType, basePower: Int, cooldown: Int, statusEffectChance: Double,
         statusEffect: StatusEffectType?, statusEffectDuration: Int = 0, effectCalculator: EffectCalculator, rarity: ItemRarity = .common) {
        self.name = name
        self.description = description
        self.type = type
        self.targetType = targetType
        self.elementType = elementType
        self.basePower = basePower
        self.cooldown = cooldown
        self.statusEffectChance = statusEffectChance
        self.statusEffect = statusEffect
        self.statusEffectDuration = statusEffectDuration
        self.effectCalculator = effectCalculator
        self.rarity = rarity
    }

    func canUse() -> Bool {
        currentCooldown == 0
    }

    func use(from source: GameStateEntity, on targets: [GameStateEntity]) -> [EffectResult] {
        var results: [EffectResult] = []

        for target in targets {
            // Calculate the effect
            let result = effectCalculator.calculate(skill: self, source: source, target: target)
            results.append(result)

            // Apply status effect if applicable
            if let effectType = statusEffect, Double.random(in: 0...1) < statusEffectChance {
                let effect = StatusEffect(type: effectType, remainingDuration: statusEffectDuration, strength: 1.0, sourceId: source.id)
                if let statusComponent = target.getComponent(ofType: StatusEffectsComponent.self) {
                    statusComponent.addEffect(effect)
                    results.append(EffectResult(entity: target, type: .statusApplied, value: 0,
                                                description: "\(target.name) is affected by \(effectType)!"))
                }
            }
        }

        startCooldown()
        return results
    }

    func startCooldown() {
        currentCooldown = cooldown
    }

    func reduceCooldown() {
        if currentCooldown > 0 {
            currentCooldown -= 1
        }
    }
}
