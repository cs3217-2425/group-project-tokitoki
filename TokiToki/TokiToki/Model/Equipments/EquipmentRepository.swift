//
//  EquipmentRepository.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation

protocol EquipmentRepositoryProtocol {
    func getAllTemplates() -> [EquipmentData]
    func getTemplate(named name: String) -> EquipmentData?
    func createEquipment(from template: EquipmentData) -> Equipment
    func createConsumableEquipment(
        name: String,
        description: String,
        rarity: Int,
        effectStrategy: ConsumableEffectStrategy,
        usageContext: ConsumableUsageContext
    ) -> ConsumableEquipment
    func createNonConsumableEquipment(
        name: String,
        description: String,
        rarity: Int,
        buff: EquipmentBuff,
        slot: EquipmentSlot
    ) -> NonConsumableEquipment
}

class EquipmentRepository: EquipmentRepositoryProtocol {
    private let logger = Logger(subsystem: "EquipmentRespository")
    private var templates: [String: EquipmentData] = [:]

    init() {
        loadTemplates()
    }

    /// All EquipmentData templates
    func getAllTemplates() -> [EquipmentData] {
        Array(templates.values)
    }

    /// Template by name
    func getTemplate(named name: String) -> EquipmentData? {
        templates[name]
    }

    func createConsumableEquipment(
        name: String,
        description: String,
        rarity: Int,
        effectStrategy: ConsumableEffectStrategy,
        usageContext: ConsumableUsageContext
    ) -> ConsumableEquipment {
        ConsumableEquipment(
            id: UUID(),
            name: name,
            description: description,
            rarity: rarity,
            effectStrategy: effectStrategy,
            usageContext: usageContext
        )
    }

    func createNonConsumableEquipment(
        name: String,
        description: String,
        rarity: Int,
        buff: EquipmentBuff,
        slot: EquipmentSlot
    ) -> NonConsumableEquipment {
        NonConsumableEquipment(
            id: UUID(),
            name: name,
            description: description,
            rarity: rarity,
            buff: buff,
            slot: slot
        )
    }

    func createEquipment(from template: EquipmentData) -> Equipment {
        // For non-consumable equipment:
        guard let buffData = template.buff,
              let slotRaw = template.slot else {
            // Fallback: no buff info
            let defaultBuff = EquipmentBuff(
                value: 0,
                description: "No stat boost",
                affectedStats: []
            )
            return createNonConsumableEquipment(
                name: template.name,
                description: template.description,
                rarity: template.rarity,
                buff: defaultBuff,
                slot: .weapon
            )
        }

        // Convert the array of stat strings -> [EquipmentBuff.Stat]
        let statsArray: [EquipmentBuff.Stat] =
            buffData.affectedStats
                    .compactMap { EquipmentBuff.Stat(rawValue: $0.lowercased()) }

        let buff = EquipmentBuff(
            value: buffData.value,
            description: buffData.description,
            affectedStats: statsArray
        )

        let equipmentSlot = convertStringToEquipmentSlot(slotRaw)

        return createNonConsumableEquipment(
            name: template.name,
            description: template.description,
            rarity: template.rarity,
            buff: buff,
            slot: equipmentSlot
        )
    }

    // MARK: - Private Methods

    private func loadTemplates() {
        do {
            let data: EquipmentsData = try ResourceLoader.loadJSON(fromFile: "Equipments")
            for eq in data.equipment {
                templates[eq.name] = eq
            }
            logger.log("Loaded \(templates.count) equipment templates")
        } catch {
            logger.logError("Failed to load equipment templates: \(error)")
        }
    }

    private func usageContext(from inBattleOnly: Bool?) -> ConsumableUsageContext {
        guard let flag = inBattleOnly else { return .anywhere }
        return flag ? .battleOnly : .outOfBattleOnly
    }

    private func convertStringToEquipmentSlot(_ str: String) -> EquipmentSlot {
        switch str.lowercased() {
        case "weapon": return .weapon
        case "armor": return .armor
        case "accessory": return .accessory
        default: return .weapon
        }
    }
}
