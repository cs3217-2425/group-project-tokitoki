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
            lastLoginDate: Date(),
            ownedTokis: [],
            pullsSinceRare: 0
        )
        savePlayer(player)
        return player
    }

    // MARK: - Helper Methods
    private func convertToPlayer(_ entity: PlayerCD) -> Player {
        let playerTokiEntities = entity.tokis as? Set<PlayerTokiCD> ?? []
        let domainPlayerTokis = playerTokiEntities.map { convertPlayerTokiToDomain($0) }

        return Player(
            id: entity.id ?? UUID(),
            name: entity.name ?? "Player",
            level: Int(entity.level),
            experience: Int(entity.experience),
            currency: Int(entity.currency),
            statistics: Player.PlayerStatistics(
                totalBattles: Int(entity.totalBattles),
                battlesWon: Int(entity.battlesWon)
            ),
            lastLoginDate: entity.lastLoginDate ?? Date(),
            ownedTokis: Array(domainPlayerTokis),
            pullsSinceRare: Int(entity.pullsSinceRare)
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
        entity.pullsSinceRare = Int32(player.pullsSinceRare)

        if let oldTokis = entity.tokis as? Set<PlayerTokiCD> {
            for oldToki in oldTokis {
                context.delete(oldToki)
            }
        }

        for domainToki in player.ownedTokis {
            let tokiEntity = PlayerTokiCD(context: context)
            tokiEntity.id = domainToki.id
            tokiEntity.dateAcquired = domainToki.dateAcquired
            tokiEntity.baseTokiId = domainToki.baseTokiId
            tokiEntity.currentHealth = Int16(domainToki.currentHealth)
            tokiEntity.currentAttack = Int16(domainToki.currentAttack)
            tokiEntity.currentDefense = Int16(domainToki.currentDefense)
            tokiEntity.currentSpeed = Int16(domainToki.currentSpeed)
            tokiEntity.player = entity
        }
    }

    // MARK: - PlayerToki <-> PlayerTokiCD

    private func convertPlayerTokiToDomain(_ playerTokiCD: PlayerTokiCD) -> PlayerToki {
        PlayerToki(
            id: playerTokiCD.id ?? UUID(),
            baseTokiId: playerTokiCD.baseTokiId ?? UUID(), // Ensure correct linking
            dateAcquired: playerTokiCD.dateAcquired ?? Date(),
            currentHealth: Int(playerTokiCD.currentHealth),
            currentAttack: Int(playerTokiCD.currentAttack),
            currentDefense: Int(playerTokiCD.currentDefense),
            currentSpeed: Int(playerTokiCD.currentSpeed)
        )
    }

}
