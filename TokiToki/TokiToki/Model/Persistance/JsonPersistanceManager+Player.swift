//
//  JsonPersistanceManager+Player.swift
//  TokiToki
//
//  Created by Wh Kang on 11/4/25.
//

import Foundation

extension JsonPersistenceManager {
    // MARK: - Player Methods
    
    func savePlayers(_ players: [Player]) -> Bool {
        let playersCodable = players.map { PlayerCodable(from: $0) }
        return saveToJson(playersCodable, filename: playersFileName)
    }
    
    func savePlayer(_ player: Player) -> Bool {
        // 1) Load existing players
        var players: [PlayerCodable] = []
        if fileExists(filename: playersFileName),
           let existingPlayers: [PlayerCodable] = loadFromJson(filename: playersFileName) {
            players = existingPlayers
        }
        
        // 2) Convert the player to codable
        let playerCodable = PlayerCodable(from: player)
        
        // 3) Update or add
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = playerCodable
        } else {
            players.append(playerCodable)
        }
        
        // 4) Save all players
        let playersSaved = saveToJson(players, filename: playersFileName)
        
        // 5) Save player’s Tokis
        let tokisSaved = savePlayerTokis(player.ownedTokis, playerId: player.id)
        
        // [FIXED] 6) Save player's equipment
        let equipmentSaved = savePlayerEquipment(player.ownedEquipments, playerId: player.id)
        
        return playersSaved && tokisSaved && equipmentSaved
    }
    
    func loadPlayers() -> [Player]? {
        guard let playersCodable: [PlayerCodable] = loadFromJson(filename: playersFileName) else {
            return nil
        }
        
        var players: [Player] = []
        
        for playerCodable in playersCodable {
            var player = playerCodable.toDomainModel()
            
            // Load Tokis
            player.ownedTokis = loadPlayerTokis(playerId: player.id) ?? []
            
            // [FIXED] Load Equipment
            player.ownedEquipments = loadPlayerEquipment(playerId: player.id) ?? EquipmentComponent()
            
            players.append(player)
        }
        
        return players
    }
    
    func loadPlayer(id: UUID) -> Player? {
        guard let playersCodable: [PlayerCodable] = loadFromJson(filename: playersFileName),
              let playerCodable = playersCodable.first(where: { $0.id == id }) else {
            return nil
        }
        
        var player = playerCodable.toDomainModel()
        
        // Load Tokis
        player.ownedTokis = loadPlayerTokis(playerId: player.id) ?? []
        
        // [FIXED] Load Equipment
        player.ownedEquipments = loadPlayerEquipment(playerId: player.id) ?? EquipmentComponent()
        
        return player
    }
    
    func deletePlayer(id: UUID) -> Bool {
        // Load existing players
        guard let playersCodable: [PlayerCodable] = loadFromJson(filename: playersFileName) else {
            return false
        }
        
        // Remove the matching player
        let updatedPlayers = playersCodable.filter { $0.id != id }
        if updatedPlayers.count == playersCodable.count {
            return false
        }
        
        // Save updated players
        let playersSaved = saveToJson(updatedPlayers, filename: playersFileName)
        
        // Delete that player’s Tokis
        let tokisDeleted = deletePlayerTokis(playerId: id)
        
        // [FIXED] Delete player’s equipment
        let equipmentDeleted = deletePlayerEquipment(playerId: id)
        
        return playersSaved && tokisDeleted && equipmentDeleted
    }
}
