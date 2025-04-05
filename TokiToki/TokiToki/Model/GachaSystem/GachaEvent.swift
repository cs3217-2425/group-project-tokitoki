//
//  GachaEvent.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//
import Foundation

class GachaEvent: IGachaEvent {
    let id = UUID()
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date

    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    init(name: String, description: String, startDate: Date, endDate: Date) {
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
    }

    func getRateModifiers() -> [String: Double] {
        [:] // Default implementation returns no modifiers
    }
}

// Element-based event
class ElementEvent: GachaEvent {
    let elementType: ElementType
    let rateMultiplier: Double
    let itemRepository: ItemRepository

    init(name: String, description: String, startDate: Date, endDate: Date,
         elementType: ElementType, rateMultiplier: Double, itemRepository: ItemRepository) {
        self.elementType = elementType
        self.rateMultiplier = rateMultiplier
        self.itemRepository = itemRepository
        super.init(name: name, description: description, startDate: startDate, endDate: endDate)
    }

    override func getRateModifiers() -> [String: Double] {
        guard isActive else { return [:] }

        var modifiers: [String: Double] = [:]

        // Apply boost to all items of the target element type
        let tokiTemplates = itemRepository.getAllTokiTemplates()
        let skillTemplates = itemRepository.getAllSkillTemplates()
        let equipmentTemplates = itemRepository.getAllEquipmentTemplates()

        // Tokis
        let tokiModifiers = tokiTemplates
            .filter { convertStringToElement($0.elementType) == elementType }
            .reduce(into: [String: Double]()) { result, toki in
                result[toki.name] = rateMultiplier
            }

        // Skills
        let skillModifiers = skillTemplates
            .filter { convertStringToElement($0.elementType) == elementType }
            .reduce(into: [String: Double]()) { result, skill in
                result[skill.name] = rateMultiplier
            }

        // Equipment
        let equipmentModifiers = equipmentTemplates
            .filter { convertStringToElement($0.elementType) == elementType }
            .reduce(into: [String: Double]()) { result, equipment in
                result[equipment.name] = rateMultiplier
            }

        modifiers.merge(tokiModifiers) { _, new in new }
        modifiers.merge(skillModifiers) { _, new in new }
        modifiers.merge(equipmentModifiers) { _, new in new }

        return modifiers
    }

    // Helper method to convert string to ElementType
    private func convertStringToElement(_ str: String) -> ElementType {
        switch str.lowercased() {
        case "fire": return .fire
        case "water": return .water
        case "earth": return .earth
        case "air": return .air
        case "light": return .light
        case "dark": return .dark
        default: return .neutral
        }
    }
}

// Specific item boost event
class ItemBoostEvent: GachaEvent {
    let targetItemNames: [String]
    let rateMultiplier: Double

    init(name: String, description: String, startDate: Date, endDate: Date,
         targetItemNames: [String], rateMultiplier: Double) {
        self.targetItemNames = targetItemNames
        self.rateMultiplier = rateMultiplier
        super.init(name: name, description: description, startDate: startDate, endDate: endDate)
    }

    override func getRateModifiers() -> [String: Double] {
        guard isActive else { return [:] }

        var modifiers: [String: Double] = [:]

        // Apply boost to specific items by name
        for itemName in targetItemNames {
            modifiers[itemName] = rateMultiplier
        }

        return modifiers
    }
}
