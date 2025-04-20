//
//  GachaEvent.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//
import Foundation

protocol IGachaEvent: Identifiable {
    var name: String { get }
    var description: String { get }
    var startDate: Date { get }
    var endDate: Date { get }
    var isActive: Bool { get }

    // Returns rate modifiers for specific items
    func getRateModifiers() -> [String: Double]
}

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
    private let tokiFactory: TokiFactoryProtocol
    private let equipmentFactory: EquipmentFactoryProtocol

    init(name: String, description: String, startDate: Date, endDate: Date,
         elementType: ElementType, rateMultiplier: Double,
         tokiFactory: TokiFactoryProtocol, equipmentFactory: EquipmentFactoryProtocol) {
        self.elementType = elementType
        self.rateMultiplier = rateMultiplier
        self.tokiFactory = tokiFactory
        self.equipmentFactory = equipmentFactory
        super.init(name: name, description: description, startDate: startDate, endDate: endDate)
    }

    override func getRateModifiers() -> [String: Double] {
        guard isActive else { return [:] }

        var modifiers: [String: Double] = [:]

        // Apply modifiers to all Tokis with matching element
        for tokiTemplate in tokiFactory.getAllTemplates() {
            if let tokiElementType = ElementType.fromString(tokiTemplate.elementType),
               tokiElementType == elementType {
                modifiers[tokiTemplate.name] = rateMultiplier
            }
        }

        // Apply modifiers to all Equipment with matching element
        for equipmentTemplate in equipmentFactory.getAllTemplates() {
            if let equipmentElementType = ElementType.fromString(equipmentTemplate.elementType),
               equipmentElementType == elementType {
                modifiers[equipmentTemplate.name] = rateMultiplier
            }
        }
        
        print("Modifiers for \(elementType): \(modifiers)")

        return modifiers
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

        // Apply boost to specific items by name
        return Dictionary(uniqueKeysWithValues: targetItemNames.map { ($0, rateMultiplier) })
    }
}

// Rarity-based event
class RarityEvent: GachaEvent {
    let targetRarity: ItemRarity
    let rateMultiplier: Double
    private let tokiFactory: TokiFactoryProtocol
    private let equipmentFactory: EquipmentFactoryProtocol

    init(name: String, description: String, startDate: Date, endDate: Date,
         targetRarity: ItemRarity, rateMultiplier: Double,
         tokiFactory: TokiFactoryProtocol, equipmentFactory: EquipmentFactoryProtocol) {
        self.targetRarity = targetRarity
        self.rateMultiplier = rateMultiplier
        self.tokiFactory = tokiFactory
        self.equipmentFactory = equipmentFactory
        super.init(name: name, description: description, startDate: startDate, endDate: endDate)
    }

    override func getRateModifiers() -> [String: Double] {
        guard isActive else { return [:] }

        var modifiers: [String: Double] = [:]

        // Apply modifiers to all Tokis with matching rarity
        for tokiTemplate in tokiFactory.getAllTemplates() {
            let rarityValue = ItemRarity(intValue: tokiTemplate.rarity) ?? .common
            if rarityValue == targetRarity {
                modifiers[tokiTemplate.name] = rateMultiplier
            }
        }

        // Apply modifiers to all Equipment with matching rarity
        for equipmentTemplate in equipmentFactory.getAllTemplates() {
            let rarityValue = ItemRarity(intValue: equipmentTemplate.rarity) ?? .common
            if rarityValue == targetRarity {
                modifiers[equipmentTemplate.name] = rateMultiplier
            }
        }

        return modifiers
    }
}
