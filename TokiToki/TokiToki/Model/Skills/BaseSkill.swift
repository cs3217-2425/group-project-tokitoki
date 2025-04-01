//
//  BaseSkill.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class BaseSkill: Skill {
    //let id = UUID()
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
    let statusEffectStrength: Double
    let statsModifiers: [StatsModifier]

    private let effectCalculator: EffectCalculator

    init(name: String, description: String, type: SkillType, targetType: TargetType,
         elementType: ElementType, basePower: Int, cooldown: Int, statusEffectChance: Double,
         statusEffect: StatusEffectType?, statusEffectDuration: Int = 0, effectCalculator: EffectCalculator,
         statusEffectStrength: Double = 1.0, statsModifiers: [StatsModifier] = []) {
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
        self.statusEffectStrength = statusEffectStrength
        self.statsModifiers = statsModifiers
    }

    func canUse() -> Bool {
        currentCooldown == 0
    }

    func use(from source: GameStateEntity, on targets: [GameStateEntity]) -> [EffectResult] {
        var results: [EffectResult] = []

        for target in targets {
            let result = effectCalculator.calculate(skill: self, source: source, target: target)
            results.append(result)

            applyStatusEffectIfApplicable(source, target, &results)
            applyStatsModifiersIfApplicable(target, &results)
        }

        startCooldown()
        return results
    }
    
    private func applyStatsModifiersIfApplicable(_ target: GameStateEntity, _ results: inout [EffectResult]) {
        for modifier in statsModifiers {
            guard let statsModifiersComponent = target.getComponent(ofType: StatsModifiersComponent.self) else {
                return
            }
            StatsModifiersSystem().addModifier(modifier, target)
            results.append(EffectResult(entity: target, type: .statsModified, value: 0,
                                        description: modifier.describeChanges(for: target)))
        }
    }
    
    fileprivate func applyStatusEffectIfApplicable(_ source: GameStateEntity,
                                                   _ target: GameStateEntity, _ results: inout [EffectResult]) {
        if let effectType = statusEffect, Double.random(in: 0...1) < statusEffectChance {
            let effect = StatusEffect(type: effectType, remainingDuration: statusEffectDuration,
                                      strength: statusEffectStrength,
                                      sourceId: source.id)
            guard let statusComponent = target.getComponent(ofType: StatusEffectsComponent.self) else {
                return
            }
            StatusEffectsSystem().addEffect(effect, target)
            results.append(EffectResult(entity: target, type: .statusApplied, value: 0,
                                        description: "\(target.name) is affected by \(effectType)!"))
        }
    }

    func startCooldown() {
        currentCooldown = cooldown
    }

    func reduceCooldown() {
        if currentCooldown > 0 {
            currentCooldown -= 1
        }
    }
    
    func resetCooldown() {
        currentCooldown = 0
    }
}
