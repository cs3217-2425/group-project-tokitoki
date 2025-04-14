//
//  JsonPersistanceManager+Toki.swift
//  TokiToki
//
//  Created by Wh Kang on 11/4/25.
//

import Foundation

extension JsonPersistenceManager {
    func savePlayerTokis(_ tokis: [Toki], playerId: UUID) -> Bool {
        let tokisCodable = tokis.map { TokiCodable(from: $0, ownerId: playerId) }

        var allTokis: [TokiCodable] = []
        if fileExists(filename: playerTokisFileName),
           let existingTokis: [TokiCodable] = loadFromJson(filename: playerTokisFileName) {
            // Keep tokis from other players
            allTokis = existingTokis.filter { $0.ownerId != playerId }
        }

        // Add current player's tokis
        allTokis.append(contentsOf: tokisCodable)

        return saveToJson(allTokis, filename: playerTokisFileName)
    }

    func loadPlayerTokis(playerId: UUID) -> [Toki]? {
        // Load all tokis from JSON.
        guard let allTokisCodable: [TokiCodable] = loadFromJson(filename: playerTokisFileName) else {
            return []
        }

        // Filter only the tokis for this player.
        let playerTokisCodable = allTokisCodable.filter { $0.ownerId == playerId }

        // Load the player's equipment component.
        guard let equipmentComponent = loadPlayerEquipment(playerId: playerId) else {
            print("No equipment component found for player \(playerId)")
            return nil
        }

        // Build a lookup dictionary keyed by UUID.
        let equipmentLookup = Dictionary(uniqueKeysWithValues: equipmentComponent.inventory.map { ($0.id, $0) })

        var tokis: [Toki] = []

        for tokiCodable in playerTokisCodable {
            // Convert the TokiCodable to a domain model.
            let toki = tokiCodable.toDomainModel()

            // Load the matching skills from the stored skill names.
            let skillsForThisToki: [Skill] = tokiCodable.skillNames.compactMap { skillName in
                guard let skillData = skillTemplates[skillName] else {
                    print("Skill template not found for name: \(skillName)")
                    return nil
                }
                return skillsFactory.createSkill(from: skillData)
            }
            toki.skills = skillsForThisToki

            // Use the toki's equipmentIds (of type UUID) to retrieve Equipment from the lookup dictionary.
            let equipmentsForThisToki: [Equipment] = tokiCodable.equipmentIds.compactMap { equipmentId in
                equipmentLookup[equipmentId]
            }
            toki.equipments = equipmentsForThisToki
            print("[JsonPersistentManager] Loaded Toki: \(toki.name) with \(toki.equipments.count) equipments and \(toki.skills.count) skills.")

            tokis.append(toki)
        }

        return tokis
    }

    func deletePlayerTokis(playerId: UUID) -> Bool {
        guard let allTokisCodable: [TokiCodable] = loadFromJson(filename: playerTokisFileName) else {
            return true
        }

        let updatedTokis = allTokisCodable.filter { $0.ownerId != playerId }
        return saveToJson(updatedTokis, filename: playerTokisFileName)
    }
}
