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
        tokiFactory.createToki(from: template)
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
    private let equipmentRepository: EquipmentRepositoryProtocol

    var ownerId: UUID?
    var dateAcquired: Date?

    init(template: EquipmentData, equipmentRepository: EquipmentRepositoryProtocol) {
        self.template = template
        self.equipmentRepository = equipmentRepository
        self.name = template.name
        self.rarity = ItemRarity(intValue: template.rarity) ?? .common
    }

    func createInstance() -> Any {
        equipmentRepository.createEquipment(from: template)
    }
}
