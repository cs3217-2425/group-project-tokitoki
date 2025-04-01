//
//  GachaEvent.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//
import Foundation

class GachaEvent: IGachaEvent {
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
        return [:] // Default implementation returns no modifiers
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
        // For Toki templates
        for (name, toki) in itemRepository.getAllTokiTemplatesByName() where toki.elementType == elementType {
            modifiers[name] = rateMultiplier
        }
        
        // For Skill templates
        for (name, skill) in itemRepository.getAllSkillTemplatesByName() where skill.elementType == elementType {
            modifiers[name] = rateMultiplier
        }
        
        // For Equipment templates
        for (name, equipment) in itemRepository.getAllEquipmentTemplatesByName() where equipment.elementType == elementType {
            modifiers[name] = rateMultiplier
        }
        
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
        
        var modifiers: [String: Double] = [:]
        
        // Apply boost to specific items by name
        for itemName in targetItemNames {
            modifiers[itemName] = rateMultiplier
        }
        
        return modifiers
    }
}
