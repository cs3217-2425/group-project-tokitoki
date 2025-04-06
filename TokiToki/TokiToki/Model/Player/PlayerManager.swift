//
//  PlayerManager.swift
//  TokiToki
//
//  Created by wesho on 19/3/25.
//

import Foundation
import CoreData

class PlayerManager {
    static let shared = PlayerManager()

    private let playerRepository: PlayerRepository
    private var currentPlayer: Player?

    private init() {
        // Use CoreData context from DataManager
        let context = DataManager.shared.viewContext
        self.playerRepository = CoreDataPlayerRepository(context: context)
        loadPlayerData()
    }
    
    // Load player data when initializing the manager
    private func loadPlayerData() {
        if let loadedPlayer = playerRepository.getPlayer() {
            currentPlayer = loadedPlayer
            print("Player loaded from Core Data: \(loadedPlayer.name)")
        } else {
            print("No saved player found in Core Data")
        }
    }

    // MARK: - Player Access

    func getPlayer() -> Player? {
        if let player = currentPlayer {
            print("Returning current player: \(player.name) \(player.currency)")
            return player
        }
        
        if let loadedPlayer = playerRepository.getPlayer() {
            currentPlayer = loadedPlayer
            return loadedPlayer
        }

        return nil
    }

    func getOrCreatePlayer(name: String = "Player") -> Player {
        if let player = getPlayer() {
            print("Returning existing player: \(player.name) \(player.currency)")
            return player
        }
        print("Creating a new player with default name: \(name)")
        
        let player = playerRepository.createDefaultPlayer(name: name)
        currentPlayer = player
        return player
    }

    private func savePlayer() {
        if let player = currentPlayer {
            playerRepository.savePlayer(player)
        }
    }

    // MARK: - Player Operations

    func addExperience(_ amount: Int) {
        var player = getOrCreatePlayer()
        player.addExperience(amount)
        currentPlayer = player
        savePlayer()
    }

    func addCurrency(_ amount: Int) {
        var player = getOrCreatePlayer()
        player.addCurrency(amount)
        currentPlayer = player
        savePlayer()
    }

    func spendCurrency(_ amount: Int) -> Bool {
        var player = getOrCreatePlayer()
        if player.spendCurrency(amount) {
            currentPlayer = player
            savePlayer()
            return true
        }
        return false
    }

    func getCurrentCurrency() -> Int {
        getOrCreatePlayer().currency
    }

    func getBattleStatistics() -> (total: Int, won: Int, winRate: Double) {
        let player = getOrCreatePlayer()
        let stats = player.statistics
        return (stats.totalBattles, stats.battlesWon, stats.winRate)
    }

    func updatePlayerName(_ newName: String) {
        var player = getOrCreatePlayer()
        player.name = newName
        currentPlayer = player
        savePlayer()
    }
    
    // MARK: - Item Management

    /// Adds a single item to the player's collection
    func addItem(_ item: any IGachaItem) {
        var player = getOrCreatePlayer()
        player.addItem(item)
        currentPlayer = player
        savePlayer()
    }

    /// Adds multiple items at once to the player's collection
    func addItems(_ items: [any IGachaItem]) {
        var player = getOrCreatePlayer()
        for item in items {
            player.addItem(item)
        }
        currentPlayer = player
        savePlayer()
    }
    
    /// Adds a skill directly to the player's collection
    func addSkill(_ skill: Skill) {
        var player = getOrCreatePlayer()
        player.ownedSkills.append(skill)
        currentPlayer = player
        savePlayer()
    }
    
    /// Adds a toki directly to the player's collection
    func addToki(_ toki: Toki) {
        var player = getOrCreatePlayer()
        player.ownedTokis.append(toki)
        currentPlayer = player
        savePlayer()
    }
    
    /// Adds equipment directly to the player's collection
    func addEquipment(_ equipment: Equipment) {
        var player = getOrCreatePlayer()
        player.ownedEquipments.append(equipment)
        currentPlayer = player
        savePlayer()
    }
    
    // MARK: - Gacha Operations
    
    /// Draw from a gacha pack, handling all player updates internally
    func drawFromGachaPack(packName: String, count: Int, gachaService: GachaService) -> [any IGachaItem] {
        // Get current player state
        var player = getOrCreatePlayer()
        
        // Find the pack
        guard let pack = gachaService.findPack(byName: packName) else {
            print("No pack found with name \(packName)")
            return []
        }
        
        // Check if player has enough currency
        let totalCost = pack.cost * count
        guard player.canSpendCurrency(totalCost) else {
            print("Player doesn't have enough currency to draw")
            return []
        }
        
        // Draw from the pack
        let drawnItems = gachaService.drawFromPack(packName: packName, count: count, for: &player)
        
        currentPlayer = player
        
        // Save player to Core Data
        savePlayer()
        
        return drawnItems
    }
    
    // MARK: - Data Management
    
    /// Reset player data (for testing or user request)
    func resetPlayerData() -> Bool {
        if playerRepository.deletePlayerData() {
            currentPlayer = nil
            return true
        }
        return false
    }
    
    /// Save player data manually (normally handled automatically)
    func savePlayerData() {
        savePlayer()
    }
    
    /// Force refresh player data from Core Data
    func refreshPlayerData() {
        currentPlayer = playerRepository.getPlayer()
    }
}
