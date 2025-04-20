//
//  PlayerManager.swift
//  TokiToki
//
//  Created by wesho on 19/3/25.
//

import Foundation
import CoreData

protocol PlayerManagerProtocol {
    // Player access
    func getPlayer() -> Player?
    func getOrCreatePlayer(name: String) -> Player
    func savePlayer()
    func getTokisForBattle() -> [Toki]
    func getFirstThreeOwnedTokis() -> [Toki]
    func resetTokisForBattle()
    func getEquipmentComponent() -> EquipmentComponent
    
    // Player operations
    func addExperience(_ amount: Int)
    func addCurrency(_ amount: Int)
    func spendCurrency(_ amount: Int) -> Bool
    func getCurrentCurrency() -> Int
    func getBattleStatistics() -> (total: Int, won: Int, winRate: Double)
    func updateBattleStatistics(isWin: Bool)
    func updatePlayerName(_ newName: String)
    func updateAfterBattle(exp: Int, gold: Int, isWin: Bool)
    
    // Daily pull limit
    func hasReachedDailyPullLimit() -> Bool
    func getRemainingDailyPulls() -> Int
    
    // Item management
    func addItem(_ item: any IGachaItem)
    func addItems(_ items: [any IGachaItem])
    func addSkill(_ skill: Skill)
    func addToki(_ toki: Toki)
    func addTokiToBattle(_ toki: Toki)
    func addEquipment(_ equipment: Equipment)
    
    // Gacha operations
    func drawFromGachaPack(packName: String, count: Int, gachaService: GachaService) -> [any IGachaItem]
    
    // Data management
    func resetPlayerData() -> Bool
    func savePlayerData()
    func refreshPlayerData()
}

class PlayerManager: PlayerManagerProtocol {
    // MARK: - Constants
    
    static let DEFAULT_DAILY_PULL_LIMIT = 3
    
    // MARK: - Properties
    
    private let persistenceManager: JsonPersistenceManager
    private let playerRepository: PlayerRepository
    private let logger = Logger(subsystem: "PlayerManager")
    private var currentPlayer: Player?
    
    // MARK: - Initialization
    
    init(persistenceManager: JsonPersistenceManager? = nil, playerRepository: PlayerRepository? = nil) {
        self.persistenceManager = persistenceManager ?? JsonPersistenceManager()
        self.playerRepository = playerRepository ?? PlayerRepository(persistenceManager: self.persistenceManager)
        loadPlayerData()
    }
    
    private func loadPlayerData() {
        if let loadedPlayer = playerRepository.getPlayer() {
            currentPlayer = loadedPlayer
        } else {
            logger.log("No saved player found in JSON storage")
        }
    }
    
    // MARK: - Player Access
    
    func getEquipmentComponent() -> EquipmentComponent {
        return getOrCreatePlayer().ownedEquipments
    }
    
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
    
    func savePlayer() {
        if let player = currentPlayer {
            playerRepository.savePlayer(player)
        }
    }
    
    func getTokisForBattle() -> [Toki] {
        return getOrCreatePlayer().tokisForBattle
    }
    
    func getFirstThreeOwnedTokis() -> [Toki] {
        return Array(getOrCreatePlayer().ownedTokis.prefix(3))
    }
    
    func resetTokisForBattle() {
        currentPlayer?.resetTokisForBattle()
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
        return getOrCreatePlayer().currency
    }
    
    func getBattleStatistics() -> (total: Int, won: Int, winRate: Double) {
        let player = getOrCreatePlayer()
        let stats = player.statistics
        return (stats.totalBattles, stats.battlesWon, stats.winRate)
    }
    
    func updateBattleStatistics(isWin: Bool) {
        var player = getOrCreatePlayer()
        player.recordBattleResult(won: isWin)
        currentPlayer = player
        savePlayer()
    }
    
    func updatePlayerName(_ newName: String) {
        var player = getOrCreatePlayer()
        player.name = newName
        currentPlayer = player
        savePlayer()
    }
    
    func updateAfterBattle(exp: Int, gold: Int, isWin: Bool) {
        addCurrency(gold)
        addExperience(exp)
        updateBattleStatistics(isWin: isWin)
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
    
    /// Adds a toki to be used for battle
    func addTokiToBattle(_ toki: Toki) {
        var player = getOrCreatePlayer()
        player.tokisForBattle.append(toki)
        currentPlayer = player
        savePlayer()
    }
    
    /// Adds equipment directly to the player's collection
    func addEquipment(_ equipment: Equipment) {
        var player = getOrCreatePlayer()
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
            logger.log("Player has reached the daily pull limit")
            return []
        }
        
        // Adjust count if it exceeds remaining pulls
        let actualCount = min(count, remainingPulls)
        
        // Find the pack
        guard let pack = gachaService.findPack(byName: packName) else {
            logger.logError("No pack found with name \(packName)")
            return []
        }
        
        // Check if player has enough currency
        let totalCost = pack.cost * actualCount
        guard player.canSpendCurrency(totalCost) else {
            logger.logError("Player doesn't have enough currency to draw")
            return []
        }
        
        // Draw from the pack
        let drawnItems = gachaService.drawFromPack(packName: packName, count: actualCount, for: &player)
        
        // Increment the daily pull count
        player.incrementDailyPullsCount(by: actualCount)
        
        currentPlayer = player
        
        // Save player
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
