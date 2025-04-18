//
//  PlayerJsonRepository.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 8/4/25.
//

import Foundation

class PlayerRepository {
    private let persistenceManager: JsonPersistenceManager
    private let logger = Logger(subsystem: "PlayerRepository")

    init(persistenceManager: JsonPersistenceManager) {
        self.persistenceManager = persistenceManager
    }

    /// Get player from JSON storage
    func getPlayer() -> Player? {
        // Load all players
        guard let players = persistenceManager.loadPlayers(),
              let firstPlayer = players.first else {
            logger.log("No player data found")
            return nil
        }

        // Return first player (for backward compatibility)
        return firstPlayer
    }

    /// Get player by ID from JSON storage
    func getPlayer(id: UUID) -> Player? {
        persistenceManager.loadPlayer(id: id)
    }

    /// Get all players from JSON storage
    func getAllPlayers() -> [Player] {
        persistenceManager.loadPlayers() ?? []
    }

    /// Save player to JSON storage
    func savePlayer(_ player: Player) {
        _ = persistenceManager.savePlayer(player)
    }

    /// Create a default player
    func createDefaultPlayer(name: String) -> Player {

        // Create player
        let player = Player(
            id: UUID(),
            name: name,
            level: 1,
            experience: 0,
            currency: 1_000,
            statistics: Player.PlayerStatistics(totalBattles: 0, battlesWon: 0),
            lastLoginDate: Date(),
            ownedTokis: [],
            ownedSkills: [],
            ownedEquipments: EquipmentComponent(),
            pullsSinceRare: 0,
            dailyPullsCount: 0,
            dailyPullsLastReset: Date()
        )

        // Save the new player
        savePlayer(player)

        return player
    }

    /// Delete all player data
    func deletePlayerData() -> Bool {
        let playersDeleted = persistenceManager.deleteJson(filename: "players")
        let tokisDeleted = persistenceManager.deleteJson(filename: "player_tokis")
        let equipmentsDeleted = persistenceManager.deleteJson(filename: "player_equipments")

        return playersDeleted && tokisDeleted && equipmentsDeleted
    }

    /// Delete a specific player
    func deletePlayer(id: UUID) -> Bool {
        persistenceManager.deletePlayer(id: id)
    }

}
