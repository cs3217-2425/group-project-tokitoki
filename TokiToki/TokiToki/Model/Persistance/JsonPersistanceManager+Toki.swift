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
        guard let allTokisCodable: [TokiCodable] = loadFromJson(filename: playerTokisFileName) else {
            return []
        }
        
        // Filter only the tokis for this player.
        let playerTokisCodable = allTokisCodable.filter { $0.ownerId == playerId }
        
        var tokis: [Toki] = []
        
        for tokiCodable in playerTokisCodable {
            // Debug: print the raw skillNames stored for this toki.
            print("TokiCodable \(tokiCodable.name) raw skillNames: \(tokiCodable.skillNames)")
            
            // Create a new, independent Toki (with empty skills)
            let toki = tokiCodable.toDomainModel()
            
            // Build skills only from THIS tokiCodable's skillNames.
            let skillsForThisToki: [Skill] = tokiCodable.skillNames.compactMap { skillName in
                guard let skillData = skillTemplates[skillName] else {
                    print("Skill template not found for name: \(skillName)")
                    return nil
                }
                return skillsFactory.createSkill(from: skillData)
            }
            toki.skills = skillsForThisToki
            
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
