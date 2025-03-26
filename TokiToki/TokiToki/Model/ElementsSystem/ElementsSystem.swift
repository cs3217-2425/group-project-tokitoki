//
//  ElementsSystem.swift
//  TokiToki
//
//  Created by wesho on 17/3/25.
//

import Foundation

class ElementsSystem {
    private var effectivenessMap: [ElementType: [ElementType: Double]] = [:]

    private var elementDataMap: [ElementType: ElementData] = [:]
    
    let SUPER_EFFECTIVE_MULTIPLIER = 1.5
    let NOT_VERY_EFFECTIVE_MULTIPLIER = 0.5
    let NEUTRAL_MULTIPLIER = 1.0
    let COMPLETELY_INEFFECTIVE_MULTIPLIER = 0.0

    init() {
        // loadElementData()
        
        // personally i feel the default effectiveness is more adaptable, cuz can easily change the multiplier
        // values using variables, compared to json.
        setupElementMatrix()
    }

    private func loadElementData() {
        do {
            // Make sure the JSON file is named correctly as "Elements.json"
            let elementsData: ElementsData = try ResourceLoader.loadJSON(fromFile: "Elements")

            // Build the effectiveness map
            for elementData in elementsData.elements {
                guard let elementType = ElementType.fromString(elementData.id) else {
                    print("Warning: Unknown element type \(elementData.id)")
                    continue
                }

                // Store the element data
                elementDataMap[elementType] = elementData

                // Create effectiveness dictionary for this element
                var effectivenessDict: [ElementType: Double] = [:]

                // Map the effectiveness values
                for (targetId, value) in elementData.effectiveness {
                    if let targetType = ElementType.fromString(targetId) {
                        effectivenessDict[targetType] = value
                    }
                }

                effectivenessMap[elementType] = effectivenessDict
            }
        } catch {
            print("Error loading element data: \(error)")
            // Use hard-coded default effectiveness if custom Elements.json does not exist
           // setupDefaultEffectiveness()
        }
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
    
//    // Fallback to default values if loading fails
//    private func setupDefaultEffectiveness() {
//        // Fire effectiveness
//        effectivenessMap[.fire] = [
//            .earth: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .water: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .fire: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .air: SUPER_EFFECTIVE_MULTIPLIER,
//            .light: NEUTRAL_MULTIPLIER,
//            .dark: NEUTRAL_MULTIPLIER,
//            .neutral: NEUTRAL_MULTIPLIER,
//            .ice: SUPER_EFFECTIVE_MULTIPLIER,
//            .lightning: NEUTRAL_MULTIPLIER
//        ]
//
//        // Water effectiveness
//        effectivenessMap[.water] = [
//            .fire: SUPER_EFFECTIVE_MULTIPLIER,
//            .earth: SUPER_EFFECTIVE_MULTIPLIER,
//            .water: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .air: NEUTRAL_MULTIPLIER,
//            .light: NEUTRAL_MULTIPLIER,
//            .dark: NEUTRAL_MULTIPLIER,
//            .neutral: NEUTRAL_MULTIPLIER,
//            .ice: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .lightning: NEUTRAL_MULTIPLIER
//        ]
//
//        // Earth effectiveness
//        effectivenessMap[.earth] = [
//            .air: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .water: NEUTRAL_MULTIPLIER,
//            .fire: SUPER_EFFECTIVE_MULTIPLIER,
//            .earth: NEUTRAL_MULTIPLIER,
//            .light: NEUTRAL_MULTIPLIER,
//            .dark: NEUTRAL_MULTIPLIER,
//            .neutral: NEUTRAL_MULTIPLIER,
//            .ice: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .lightning: SUPER_EFFECTIVE_MULTIPLIER
//        ]
//
//        // Air effectiveness
//        effectivenessMap[.air] = [
//            .earth: SUPER_EFFECTIVE_MULTIPLIER,
//            .fire: NEUTRAL_MULTIPLIER,
//            .water: NEUTRAL_MULTIPLIER,
//            .air: NEUTRAL_MULTIPLIER,
//            .light: NEUTRAL_MULTIPLIER,
//            .dark: NEUTRAL_MULTIPLIER,
//            .neutral: NEUTRAL_MULTIPLIER,
//            .ice: NEUTRAL_MULTIPLIER,
//            .lightning: NOT_VERY_EFFECTIVE_MULTIPLIER
//        ]
//
//        // Light effectiveness
//        effectivenessMap[.light] = [
//            .dark: SUPER_EFFECTIVE_MULTIPLIER,
//            .light: NEUTRAL_MULTIPLIER,
//            .fire: NEUTRAL_MULTIPLIER,
//            .water: NEUTRAL_MULTIPLIER,
//            .earth: NEUTRAL_MULTIPLIER,
//            .air: NEUTRAL_MULTIPLIER,
//            .neutral: NEUTRAL_MULTIPLIER,
//            .ice: NEUTRAL_MULTIPLIER,
//            .lightning: NEUTRAL_MULTIPLIER
//        ]
//
//        // Dark effectiveness
//        effectivenessMap[.dark] = [
//            .light: SUPER_EFFECTIVE_MULTIPLIER,
//            .dark: NEUTRAL_MULTIPLIER,
//            .fire: NEUTRAL_MULTIPLIER,
//            .water: NEUTRAL_MULTIPLIER,
//            .earth: NEUTRAL_MULTIPLIER,
//            .air: 1.0,
//            .neutral: 1.0,
//            .ice: 1.0,
//            .lightning: 1.0
//        ]
//
//        // Neutral effectiveness
//        effectivenessMap[.neutral] = [
//            .fire: 1.0,
//            .water: 1.0,
//            .earth: 1.0,
//            .air: 1.0,
//            .light: 1.0,
//            .dark: 1.0,
//            .neutral: 1.0,
//            .ice: 1.0,
//            .lightning: 1.0
//        ]
//
//        // Ice effectiveness
//        effectivenessMap[.ice] = [
//            .fire: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .water: NEUTRAL_MULTIPLIER,
//            .earth: SUPER_EFFECTIVE_MULTIPLIER,
//            .air: SUPER_EFFECTIVE_MULTIPLIER,
//            .light: 1.0,
//            .dark: 1.0,
//            .neutral: 1.0,
//            .ice: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .lightning: 1.0
//        ]
//
//        // Lightning effectiveness
//        effectivenessMap[.lightning] = [
//            .fire: 1.0,
//            .water: SUPER_EFFECTIVE_MULTIPLIER,
//            .earth: NOT_VERY_EFFECTIVE_MULTIPLIER,
//            .air: SUPER_EFFECTIVE_MULTIPLIER,
//            .light: 1.0,
//            .dark: 1.0,
//            .neutral: 1.0,
//            .ice: 1.0,
//            .lightning: NOT_VERY_EFFECTIVE_MULTIPLIER
//        ]
//    }


    func getEffectiveness(of attackElement: ElementType, against defenseElements: [ElementType]) -> Double {
//        if let elementMatchups = effectivenessMap[attackElement],
//           let effectiveness = elementMatchups[defenseElement] {
//            return effectiveness
//        }
//
//        return 1.0
        
        return defenseElements.reduce(1.0) { result, defenseElement in
            result * (effectivenessMap[attackElement]?[defenseElement] ?? NEUTRAL_MULTIPLIER)
        }
    }
    
    func setEffectiveness(attacker: ElementType, targets: [ElementType], value: Double) {
        for target in targets {
           effectivenessMap[attacker, default: [:]][target] = value
       }
    }

    func getElementName(_ elementType: ElementType) -> String {
        elementDataMap[elementType]?.name ?? elementType.rawValue.capitalized
    }

    func getElementDescription(_ elementType: ElementType) -> String {
        elementDataMap[elementType]?.description ?? ""
    }

    func reloadData() {
        effectivenessMap.removeAll()
        elementDataMap.removeAll()
        loadElementData()
    }
}
