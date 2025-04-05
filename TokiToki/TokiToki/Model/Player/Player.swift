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
    var ownedEquipments: EquipmentComponent
    var pullsSinceRare: Int

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

    // MARK: - Item Management
    mutating func addItem(_ item: any IGachaItem) {
        switch item {
        case let toki as Toki:
            ownedTokis.append(toki)
        case let skill as BaseSkill:
            ownedSkills.append(skill)
        case let equipment as Equipment:
            ownedEquipments.inventory.append(equipment)
        default:
            print("Unknown item type: \(type(of: item))")
        }
    }

    func countConsumables() -> [ConsumableGroupings] {
        EquipmentSystem.shared.countConsumables()
    }
}
