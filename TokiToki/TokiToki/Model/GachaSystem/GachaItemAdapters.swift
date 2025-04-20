//
//  GachaItemAdapters.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 3/4/25.
//

import Foundation

// MARK: - Toki Adapter
/// Wraps a Toki template and defers instantiation.
class TokiGachaItem: IGachaItem {
    let id = UUID()
    let name: String
    let rarity: ItemRarity
    let elementType: [ElementType]
    private let template: TokiData
    private let tokiFactory: TokiFactoryProtocol

    var ownerId: UUID?
    var dateAcquired: Date?

    init(template: TokiData, tokiFactory: TokiFactoryProtocol) {
        self.template = template
        self.tokiFactory = tokiFactory
        self.name = template.name
        self.rarity = ItemRarity(intValue: template.rarity) ?? .common
        self.elementType = [ElementType(rawValue: template.elementType) ?? .neutral]
    }

    func createInstance() -> Any {
        return tokiFactory.createToki(from: template)
    }
}

// MARK: - Equipment Adapter
/// Wraps an Equipment template and defers instantiation.
class EquipmentGachaItem: IGachaItem {
    let id = UUID()
    let name: String
    let rarity: ItemRarity
    let elementType: [ElementType] = []
    private let template: EquipmentData
    private let equipmentFactory: EquipmentFactoryProtocol 

    var ownerId: UUID?
    var dateAcquired: Date?

    init(template: EquipmentData, equipmentFactory: EquipmentFactoryProtocol) {
        self.template = template
        self.equipmentFactory = equipmentFactory
        self.name = template.name
        self.rarity = ItemRarity(intValue: template.rarity) ?? .common
    }

    func createInstance() -> Any {
        return equipmentFactory.createEquipment(from: template)
    }
}
