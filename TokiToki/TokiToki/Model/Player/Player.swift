//
//  Player.swift
//  TokiToki
//
//  Created by wesho on 19/3/25.
//

import Foundation

struct Player {
    let id: UUID
    var name: String
    var level: Int
    var experience: Int
    var currency: Int
    var statistics: PlayerStatistics
    var lastLoginDate: Date
    var ownedTokis: [Toki]
    var ownedSkills: [Skill]
    var tokisForBattle: [Toki] = []
    var ownedEquipments: EquipmentComponent
    var pullsSinceRare: Int
    var dailyPullsCount: Int
    var dailyPullsLastReset: Date?

    struct PlayerStatistics {
        var totalBattles: Int
        var battlesWon: Int

        var winRate: Double {
            totalBattles > 0
                ? Double(battlesWon) / Double(totalBattles) * 100.0
                : 0.0
        }
    }

    // MARK: Helper Methods
    mutating func addExperience(_ amount: Int) {
        experience += amount
        updateLevel()
    }

    mutating func updateLevel() {
        let newLevel = 1 + experience / 1_000
        if newLevel > level {
            level = newLevel
        }
    }

    mutating func addCurrency(_ amount: Int) {
        currency += amount
    }

    func canSpendCurrency(_ amount: Int) -> Bool {
        currency >= amount
    }

    mutating func spendCurrency(_ amount: Int) -> Bool {
        if canSpendCurrency(amount) {
            currency -= amount
            return true
        }
        return false
    }

    mutating func recordBattleResult(won: Bool) {
        statistics.totalBattles += 1
        if won {
            statistics.battlesWon += 1
        }
    }

    mutating func resetTokisForBattle() {
        tokisForBattle = []
    }

    // MARK: - Item Management
    mutating func addItem(_ item: any IGachaItem) {
        switch item {
        case let toki as TokiGachaItem:
            ownedTokis.append(toki.createInstance() as! Toki)
        case let equipment as EquipmentGachaItem:
            ownedEquipments.inventory.append(equipment.createInstance() as! Equipment)
        default:
            Logger(subsystem: "Player").log("Unknown item type: \(type(of: item))")
        }
    }

    // MARK: - Gacha Pull Management

    /// Check if the player has reached their daily pull limit
    func hasReachedDailyPullLimit(limit: Int) -> Bool {
        dailyPullsCount >= limit
    }

    /// Reset daily pulls count if a new day has started
    mutating func checkAndResetDailyPulls() {
        let calendar = Calendar.current
        let today = Date()

        if let lastReset = dailyPullsLastReset {
            // Check if the current date is a different day than the last reset
            if !calendar.isDate(today, inSameDayAs: lastReset) {
                dailyPullsCount = 0
                dailyPullsLastReset = today
            }
        } else {
            // If there's no last reset date, set it to today
            dailyPullsLastReset = today
        }
    }

    /// Increment daily pulls count after a successful pull
    mutating func incrementDailyPullsCount(by count: Int = 1) {
        checkAndResetDailyPulls() // Check if we need to reset first
        dailyPullsCount += count
    }
}
