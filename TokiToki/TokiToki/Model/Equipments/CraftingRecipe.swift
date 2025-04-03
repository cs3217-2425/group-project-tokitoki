//
//  CraftingRecipe.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//


import Foundation

struct CraftingRecipe {
    let requiredEquipmentIdentifiers: [String] // e.g., ["health potion", "health potion"]
    let resultEquipmentFactory: ([Equipment]) -> Equipment?
    
    func matches(equipments: [Equipment]) -> Bool {
        guard equipments.count == requiredEquipmentIdentifiers.count else { return false }
        let sortedInput = equipments.map { $0.name.lowercased() }.sorted()
        let sortedRequired = requiredEquipmentIdentifiers.map { $0.lowercased() }.sorted()
        return sortedInput == sortedRequired
    }
}