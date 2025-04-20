//
//  BaseSkill.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class BaseSkill: Skill {
    let name: String
    let description: String
    let cooldown: Int
    var currentCooldown: Int = 0
    let effectDefinitions: [EffectDefinition]
    let targetSelectionFactory = TargetSelectionFactory()

    init(name: String, description: String,
         cooldown: Int, effectDefinitions: [EffectDefinition], skillType: SkillType? = nil) {
        self.name = name
        self.description = description
        self.cooldown = cooldown
        self.effectDefinitions = effectDefinitions
    }

    func canUse() -> Bool {
        currentCooldown == 0
    }

    func clone() -> Skill {
        BaseSkill(name: name, description: description, cooldown: cooldown,
                         effectDefinitions: effectDefinitions)
    }

    func use(from source: GameStateEntity, _ playerTeam: [GameStateEntity],
             _ opponentTeam: [GameStateEntity], _ singleTargets: [GameStateEntity],
             _ context: EffectCalculationContext) -> [EffectResult] {
        var results: [EffectResult] = []

        for effectDefinition in effectDefinitions {
            let targets: [GameStateEntity]
            if targetSelectionFactory.checkIfRequireTargetSelection(effectDefinition.targetType)
                && !singleTargets.isEmpty {
                targets = singleTargets
            } else {
                targets = targetSelectionFactory.generateTargets(source, playerTeam, opponentTeam,
                                                                 effectDefinition.targetType)
            }

            for target in targets {
                for effectCalculator in effectDefinition.effectCalculators {
                    let result = effectCalculator.calculate(moveName: self.name, source: source,
                                                            target: target, context: context)
                    guard let result = result else {
                        continue
                    }
                    results.append(result)
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

    func resetCooldown() {
        currentCooldown = 0
    }
}
