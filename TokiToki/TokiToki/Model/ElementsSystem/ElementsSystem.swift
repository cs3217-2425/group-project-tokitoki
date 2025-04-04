//
//  ElementsSystem.swift
//  TokiToki
//
//  Created by wesho on 17/3/25.
//

import Foundation

class ElementsSystem {
    private var effectivenessMap: [ElementType: [ElementType: Double]] = [:]

    let SUPER_EFFECTIVE_MULTIPLIER = 1.5
    let NOT_VERY_EFFECTIVE_MULTIPLIER = 0.5
    let NEUTRAL_MULTIPLIER = 1.0
    let COMPLETELY_INEFFECTIVE_MULTIPLIER = 0.0

    init() {
        setupElementMatrix()
    }

    private func setupElementMatrix() {
        // Super effective
        setEffectiveness(attacker: .fire, targets: [.air, .ice], value: SUPER_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .water, targets: [.fire, .earth], value: SUPER_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .earth, targets: [.fire, .lightning], value: SUPER_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .air, targets: [.earth], value: SUPER_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .light, targets: [.dark], value: SUPER_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .dark, targets: [.light], value: SUPER_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .ice, targets: [.earth, .air], value: SUPER_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .lightning, targets: [.water, .air], value: SUPER_EFFECTIVE_MULTIPLIER)

        // Not very effective
        setEffectiveness(attacker: .fire, targets: [.earth, .water, .fire], value: NOT_VERY_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .water, targets: [.water], value: NOT_VERY_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .earth, targets: [.air], value: NOT_VERY_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .air, targets: [.lightning], value: NOT_VERY_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .ice, targets: [.fire, .ice], value: NOT_VERY_EFFECTIVE_MULTIPLIER)
        setEffectiveness(attacker: .lightning, targets: [.earth], value: NOT_VERY_EFFECTIVE_MULTIPLIER)
    }

    func getEffectiveness(of attackElement: ElementType, against defenseElements: [ElementType]) -> Double {
        defenseElements.reduce(1.0) { result, defenseElement in
            result * (effectivenessMap[attackElement]?[defenseElement] ?? NEUTRAL_MULTIPLIER)
        }
    }

    func setEffectiveness(attacker: ElementType, targets: [ElementType], value: Double) {
        for target in targets {
           effectivenessMap[attacker, default: [:]][target] = value
       }
    }

    func getElementDescription(_ elementType: ElementType) -> String {
        effectivenessMap[elementType]?.description ?? ""
    }

    func reload() {
        effectivenessMap.removeAll()
    }
}
