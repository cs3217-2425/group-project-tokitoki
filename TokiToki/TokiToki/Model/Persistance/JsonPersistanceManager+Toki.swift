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
            let otherPlayerTokis = existingTokis.filter { $0.ownerId != playerId }

            // Create a dictionary for the current player's tokis keyed by their id
            var currentPlayerTokiDict = Dictionary(uniqueKeysWithValues: existingTokis.filter { $0.ownerId == playerId }.map { ($0.id, $0) })

            // For each toki being saved, update the existing entry if present by modifying it, or add a new one if it doesn't exist
            for newToki in tokisCodable {
                if var existingToki = currentPlayerTokiDict[newToki.id] {
                    // Modify the existing toki's fields with new values. For example, update the skill names and equipment IDs.
                    existingToki.skillNames = newToki.skillNames
                    existingToki.equipmentIds = newToki.equipmentIds
                    // If there are additional fields to update, they can be merged here.
                    currentPlayerTokiDict[newToki.id] = existingToki
                } else {
                    currentPlayerTokiDict[newToki.id] = newToki
                }
            }

            // Combine tokis from other players with the updated/current player's tokis
            allTokis = otherPlayerTokis + Array(currentPlayerTokiDict.values)
        } else {
            allTokis = tokisCodable
        }

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
        let equipmentLookup = Dictionary(equipmentComponent.inventory.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

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
