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
    static let DEFAULT_DAILY_PULL_LIMIT = 3

    private let persistanceManager: JsonPersistenceManager
    private let playerRepository: PlayerRepository
    private var currentPlayer: Player?

    private init() {
        persistanceManager = JsonPersistenceManager()
        playerRepository = PlayerRepository(persistenceManager: persistanceManager)
        loadPlayerData()
    }

    private func loadPlayerData() {
        if let loadedPlayer = playerRepository.getPlayer() {
            currentPlayer = loadedPlayer
        } else {
            print("No saved player found in JSON storage")
        }
    }

    func getEquipmentComponent() -> EquipmentComponent {
        getOrCreatePlayer().ownedEquipments
    }

    func countConsumables() -> [ConsumableGroupings] {
        let countsDict = getEquipmentComponent().inventory
           .filter { $0.equipmentType == .consumable }
           .reduce(into: [String: Int]()) { counts, item in
               counts[item.name, default: 0] += 1
           }

       return countsDict.map { ConsumableGroupings(name: $0.key, quantity: $0.value) }
    }
    // MARK: - Player Access

    func getPlayer() -> Player? {
        if let player = currentPlayer {
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
            return player
        }

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

    // MARK: - Daily Pull Limit Management

    /// Check if player has reached their daily pull limit
    func hasReachedDailyPullLimit() -> Bool {
        var player = getOrCreatePlayer()

        // First check if we need to reset based on the date
        player.checkAndResetDailyPulls()

        let result = player.hasReachedDailyPullLimit(limit: PlayerManager.DEFAULT_DAILY_PULL_LIMIT)

        currentPlayer = player
        savePlayer()

        return result
    }

    /// Get remaining pulls for today
    func getRemainingDailyPulls() -> Int {
        var player = getOrCreatePlayer()

        // Check if we need to reset based on the date
        player.checkAndResetDailyPulls()

        let remainingPulls = max(0, PlayerManager.DEFAULT_DAILY_PULL_LIMIT - player.dailyPullsCount)

        currentPlayer = player
        savePlayer()

        return remainingPulls
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
        let player = getOrCreatePlayer()
        player.ownedEquipments.inventory.append(equipment)
        currentPlayer = player
        savePlayer()
    }

    // MARK: - Gacha Operations

    /// Draw from a gacha pack, handling all player updates internally
    func drawFromGachaPack(packName: String, count: Int, gachaService: GachaService) -> [any IGachaItem] {
        // Get current player state
        var player = getOrCreatePlayer()

        // First check if we need to reset based on the date
        player.checkAndResetDailyPulls()

        // Check daily pull limit
        let remainingPulls = PlayerManager.DEFAULT_DAILY_PULL_LIMIT - player.dailyPullsCount
        if remainingPulls <= 0 {
            print("Player has reached the daily pull limit")
            return []
        }

        // Adjust count if it exceeds remaining pulls
        let actualCount = min(count, remainingPulls)

        // Find the pack
        guard let pack = gachaService.findPack(byName: packName) else {
            print("No pack found with name \(packName)")
            return []
        }

        // Check if player has enough currency
        let totalCost = pack.cost * actualCount
        guard player.canSpendCurrency(totalCost) else {
            print("Player doesn't have enough currency to draw")
            return []
        }

        // Draw from the pack
        let drawnItems = gachaService.drawFromPack(packName: packName, count: actualCount, for: &player)

        // Increment the daily pull count
        player.incrementDailyPullsCount(by: actualCount)

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

struct ConsumableGroupings {
    let name: String
    let quantity: Int
}
