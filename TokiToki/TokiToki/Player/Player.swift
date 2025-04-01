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
    var ownedEquipments: [Equipment]
    var pullsSinceRare: Int
    
    // MARK: Initialization
    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        experience: Int = 0,
        currency: Int = 1000,
        statistics: PlayerStatistics = PlayerStatistics(totalBattles: 0, battlesWon: 0),
        lastLoginDate: Date = Date(),
        ownedTokis: [Toki] = [],
        ownedSkills: [Skill] = [],
        ownedEquipments: [Equipment] = [],
        pullsSinceRare: Int = 0
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.experience = experience
        self.currency = currency
        self.statistics = statistics
        self.lastLoginDate = lastLoginDate
        self.ownedTokis = ownedTokis
        self.ownedSkills = ownedSkills
        self.ownedEquipments = ownedEquipments
        self.pullsSinceRare = pullsSinceRare
    }
    
    struct PlayerStatistics {
        var totalBattles: Int
        var battlesWon: Int

        var winRate: Double {
            totalBattles > 0
                ? Double(battlesWon) / Double(totalBattles) * 100.0
                : 0.0
        }
    }
    
    // MARK: - Item Management
    mutating func addItem(_ item: any IGachaItem) {
        switch item {
        case let toki as Toki:
            ownedTokis.append(toki)
        case let skill as BaseSkill:
            ownedSkills.append(skill)
        case let equipment as Equipment:
            ownedEquipments.append(equipment)
        default:
            print("Unknown item type: \(type(of: item))")
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
}

