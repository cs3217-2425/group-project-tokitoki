//
//  PlayerManager.swift
//  TokiToki
//
//  Created by wesho on 19/3/25.
//

import Foundation

class PlayerManager {
    static let shared = PlayerManager()

    // private let playerRepository: PlayerRepository
    private var currentPlayer: Player?

    private init() {
        // Use CoreData context in DataManager since its the single access point
        let context = DataManager.shared.viewContext
        // self.playerRepository = CoreDataPlayerRepository(context: context)
    }

    // MARK: Player Access

    func getPlayer() -> Player? {
        if let player = currentPlayer {
            return player
        }

//        if let storedPlayer = playerRepository.getPlayer() {
//            currentPlayer = storedPlayer
//            return storedPlayer
//        }

        return nil
    }

    func getOrCreatePlayer(name: String = "Player") -> Player {
        if let player = getPlayer() {
            return player
        }
        
        let player = Player(
                    id: UUID(),
                    name: name,
                    level: 1,
                    experience: 0,
                    currency: 1000,
                    statistics: Player.PlayerStatistics(totalBattles: 0, battlesWon: 0),
                    lastLoginDate: Date(),
                    ownedTokis: [],
                    ownedSkills: [],
                    ownedEquipments: [],
                    pullsSinceRare: 0
                )

        // let newPlayer = playerRepository.createDefaultPlayer(name: name)
//        currentPlayer = newPlayer
//        return newPlayer
        return player
    }

    private func savePlayer() {
//        if let player = currentPlayer {
//            playerRepository.savePlayer(player)
//        }
    }

    // MARK: Player Operations

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

    /// Retrieve all Tokis owned by the player
    func getOwnedTokis() -> [Toki] {
        let player = getOrCreatePlayer()
        return player.ownedTokis
    }
    
    /// Retrieve all Skills owned by the player
    func getOwnedSkills() -> [Skill] {
        let player = getOrCreatePlayer()
        return player.ownedSkills
    }
    
    /// Retrieve all Equipment owned by the player
    func getOwnedEquipment() -> [Equipment] {
        let player = getOrCreatePlayer()
        return player.ownedEquipments
    }
}
