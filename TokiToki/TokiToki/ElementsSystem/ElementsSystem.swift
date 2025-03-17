//
//  ElementsSystem.swift
//  TokiToki
//
//  Created by wesho on 17/3/25.
//

import Foundation

class DataDrivenElementSystem {
    private var effectivenessMap: [ElementType: [ElementType: Double]] = [:]
    
    private var elementDataMap: [ElementType: ElementData] = [:]
    
    init() {
        loadElementData()
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
            setupDefaultEffectiveness()
        }
    }
    
    // Fallback to default values if loading fails
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
        if let elementMatchups = effectivenessMap[attackElement],
           let effectiveness = elementMatchups[defenseElement] {
            return effectiveness
        }
        
        return 1.0
    }
    
    func getElementName(_ elementType: ElementType) -> String {
        return elementDataMap[elementType]?.name ?? elementType.rawValue.capitalized
    }
    
    func getElementDescription(_ elementType: ElementType) -> String {
        return elementDataMap[elementType]?.description ?? ""
    }
    
    func reloadData() {
        effectivenessMap.removeAll()
        elementDataMap.removeAll()
        loadElementData()
    }
}
