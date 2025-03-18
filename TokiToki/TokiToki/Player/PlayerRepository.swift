//
//  PlayerRepository.swift
//  TokiToki
//
//  Created by wesho on 19/3/25.
//

import CoreData
import Foundation

protocol PlayerRepository {
    func getPlayer() -> Player?
    func savePlayer(_ player: Player)
    func createDefaultPlayer(name: String) -> Player
}

class CoreDataPlayerRepository: PlayerRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getPlayer() -> Player? {
        let fetchRequest: NSFetchRequest<PlayerCD> = PlayerCD.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)
            if let playerEntity = results.first {
                return convertToPlayer(playerEntity)
            }
            return nil
        } catch {
            print("Error fetching player: \(error)")
            return nil
        }
    }

    func savePlayer(_ player: Player) {
        // Check if player exists first
        let fetchRequest: NSFetchRequest<PlayerCD> = PlayerCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", player.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            let playerEntity: PlayerCD

            if let existingPlayer = results.first {
                // Update existing player
                playerEntity = existingPlayer
            } else {
                // Create new player
                playerEntity = PlayerCD(context: context)
                playerEntity.id = player.id
            }

            // Update fields
            updateEntityFromPlayer(playerEntity, player)

            try context.save()
        } catch {
            print("Error saving player: \(error)")
        }
    }

    func createDefaultPlayer(name: String) -> Player {
        let player = Player(
            id: UUID(),
            name: name,
            level: 1,
            experience: 0,
            currency: 1_000,
            statistics: Player.PlayerStatistics(totalBattles: 0, battlesWon: 0),
            lastLoginDate: Date()
        )

        savePlayer(player)
        return player
    }

    // MARK: - Helper Methods
    private func convertToPlayer(_ entity: PlayerCD) -> Player {
        Player(
            id: entity.id ?? UUID(),
            name: entity.name ?? "Player",
            level: Int(entity.level),
            experience: Int(entity.experience),
            currency: Int(entity.currency),
            statistics: Player.PlayerStatistics(
                totalBattles: Int(entity.totalBattles),
                battlesWon: Int(entity.battlesWon)
            ),
            lastLoginDate: entity.lastLoginDate ?? Date()
        )
    }

    private func updateEntityFromPlayer(_ entity: PlayerCD, _ player: Player) {
        entity.id = player.id
        entity.name = player.name
        entity.level = Int32(player.level)
        entity.experience = Int32(player.experience)
        entity.currency = Int32(player.currency)
        entity.totalBattles = Int32(player.statistics.totalBattles)
        entity.battlesWon = Int32(player.statistics.battlesWon)
        entity.lastLoginDate = player.lastLoginDate
    }
}
