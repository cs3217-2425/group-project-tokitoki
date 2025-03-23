//
//  Untitled.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class OutdatedelementsSystem {
    private var effectivenessMap: [ElementType: [ElementType: Double]] = [:]

    init() {
        setupDefaultEffectiveness()
    }

    private func setupDefaultEffectiveness() {
        // Fire effectiveness
        effectivenessMap[.fire] = [
            .earth: 1.5,
            .water: 0.5,
            .fire: 0.5,
            .air: 1.0,
            .light: 1.0,
            .dark: 1.0,
            .neutral: 1.0
        ]

        // Water effectiveness
        effectivenessMap[.water] = [
            .fire: 1.5,
            .earth: 0.5,
            .water: 0.5,
            .air: 1.0,
            .light: 1.0,
            .dark: 1.0,
            .neutral: 1.0
        ]

        // Earth effectiveness
        effectivenessMap[.earth] = [
            .air: 1.5,
            .water: 1.5,
            .fire: 0.5,
            .earth: 0.5,
            .light: 1.0,
            .dark: 1.0,
            .neutral: 1.0
        ]

        // Air effectiveness
        effectivenessMap[.air] = [
            .earth: 0.5,
            .fire: 1.5,
            .water: 1.0,
            .air: 0.5,
            .light: 1.0,
            .dark: 1.0,
            .neutral: 1.0
        ]

        // Light effectiveness
        effectivenessMap[.light] = [
            .dark: 1.5,
            .light: 0.5,
            .fire: 1.0,
            .water: 1.0,
            .earth: 1.0,
            .air: 1.0,
            .neutral: 1.0
        ]

        // Dark effectiveness
        effectivenessMap[.dark] = [
            .light: 1.5,
            .dark: 0.5,
            .fire: 1.0,
            .water: 1.0,
            .earth: 1.0,
            .air: 1.0,
            .neutral: 1.0
        ]

        // Neutral effectiveness
        effectivenessMap[.neutral] = [
            .fire: 1.0,
            .water: 1.0,
            .earth: 1.0,
            .air: 1.0,
            .light: 1.0,
            .dark: 1.0,
            .neutral: 1.0
        ]
    }

    func getEffectiveness(of attackElement: ElementType, against defenseElement: ElementType) -> Double {
        guard let elementMatchups = effectivenessMap[attackElement] else {
            return 1.0 // Default if not found
        }

        return elementMatchups[defenseElement] ?? 1.0
    }

    func setEffectiveness(of attackElement: ElementType, against defenseElement: ElementType, value: Double) {
        if effectivenessMap[attackElement] == nil {
            effectivenessMap[attackElement] = [:]
        }

        effectivenessMap[attackElement]?[defenseElement] = value
    }

    func addNewElement(_ element: ElementType, withEffectiveness effectiveness: [ElementType: Double]) {
        effectivenessMap[element] = effectiveness
    }
}
