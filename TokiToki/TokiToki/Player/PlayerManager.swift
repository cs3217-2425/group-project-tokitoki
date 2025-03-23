//
//  PlayerManager.swift
//  TokiToki
//
//  Created by wesho on 19/3/25.
//

import Foundation

class PlayerManager {
    static let shared = PlayerManager()

    private let playerRepository: PlayerRepository
    private var currentPlayer: Player?

    private init() {
        // Use CoreData context in DataManager since its the single access point
        let context = DataManager.shared.viewContext
        self.playerRepository = CoreDataPlayerRepository(context: context)
    }

    // MARK: Player Access

    func getPlayer() -> Player? {
        if let player = currentPlayer {
            return player
        }

        if let storedPlayer = playerRepository.getPlayer() {
            currentPlayer = storedPlayer
            return storedPlayer
        }

        return nil
    }

    func getOrCreatePlayer(name: String = "Player") -> Player {
        if let player = getPlayer() {
            return player
        }

        let newPlayer = playerRepository.createDefaultPlayer(name: name)
        currentPlayer = newPlayer
        return newPlayer
    }

    private func savePlayer() {
        if let player = currentPlayer {
            playerRepository.savePlayer(player)
        }
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
        return getOrCreatePlayer().currency
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
    
    // MARK: - PlayerTokis

    /// Adds a single PlayerToki to the player's owned list.
    func addPlayerToki(_ playerToki: PlayerToki) {
        var player = getOrCreatePlayer()
        player.ownedTokis.append(playerToki)
        currentPlayer = player
        savePlayer()
    }

    /// Adds multiple PlayerToki at once.
    func addPlayerTokis(_ tokis: [PlayerToki]) {
        var player = getOrCreatePlayer()
        player.ownedTokis.append(contentsOf: tokis)
        currentPlayer = player
        savePlayer()
    }

    /// Retrieve the player's entire Toki collection.
    func getOwnedPlayerTokis() -> [PlayerToki] {
        let player = getOrCreatePlayer()
        return player.ownedTokis
    }
}
