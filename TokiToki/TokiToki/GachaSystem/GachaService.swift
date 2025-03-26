//
//  GachaService.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import Foundation
import CoreData

class GachaService {
    private let gachaRepository: GachaRepository
    private let context: NSManagedObjectContext

    init(gachaRepository: GachaRepository, context: NSManagedObjectContext) {
        self.gachaRepository = gachaRepository
        self.context = context
    }

    func drawPack(packId: UUID, for player: inout Player) -> [PlayerToki] {
        guard let pack = gachaRepository.findPack(by: packId) else {
            print("No pack found with ID \(packId)")
            return []
        }

        let chosenRarity = pickRarity(from: pack.rarityDropRates, for: &player)

        var candidates = pack.containedTokis.filter { $0.rarity == chosenRarity }
        if candidates.isEmpty {
            print("No candidate Tokis in rarity \(chosenRarity) for pack \(pack.name). Fallback to .common.")
            candidates = pack.containedTokis.filter { $0.rarity == .common }

            // If even .common has no candidates, return empty
            if candidates.isEmpty {
                print("No .common Tokis either. Nothing to pull.")
                return []
            }
        }

        guard let baseToki = candidates.randomElement() else {
            return []
        }

        guard let newPlayerToki = createPlayerToki(for: baseToki) else {
            return []
        }

        if baseToki.rarity == .rare || baseToki.rarity == .legendary {
            player.pullsSinceRare = 0
        } else {
            player.pullsSinceRare += 1
        }
        player.ownedTokis.append(newPlayerToki)

        return [newPlayerToki]
    }

    private func pickRarity(from distribution: [TokiRarity: Double], for player: inout Player) -> TokiRarity {
        // If pity triggered (e.g. 100 draws since Rare), force Rare
        if player.pullsSinceRare >= 100 {
            print("Pity triggered -> force Rare or above!")
            return .rare
        }

        let roll = Double.random(in: 0.0...1.0)
        var cumulative = 0.0
        for (rarity, prob) in distribution {
            cumulative += prob
            if roll <= cumulative {
                return rarity
            }
        }
        return .common
    }

    private func createPlayerToki(for baseToki: Toki) -> PlayerToki? {
        let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", baseToki.id as CVarArg)

        guard let baseTokiCD = try? context.fetch(fetchRequest).first else {
            print("Could not find TokiCD for ID \(baseToki.id)")
            return nil
        }

        let playerTokiCD = PlayerTokiCD(context: context)
        playerTokiCD.id = UUID()
        playerTokiCD.baseTokiId = baseTokiCD.id
        playerTokiCD.dateAcquired = Date()
        playerTokiCD.currentHealth = baseTokiCD.baseHealth
        playerTokiCD.currentAttack = baseTokiCD.baseAttack
        playerTokiCD.currentDefense = baseTokiCD.baseDefense
        playerTokiCD.currentSpeed = baseTokiCD.baseSpeed

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving PlayerTokiCD: \(error)")
                return nil
            }
        }

        return PlayerToki(
            id: playerTokiCD.id ?? UUID(),
            baseTokiId: baseTokiCD.id ?? UUID(),
            dateAcquired: playerTokiCD.dateAcquired ?? Date(),
            currentHealth: Int(playerTokiCD.currentHealth),
            currentAttack: Int(playerTokiCD.currentAttack),
            currentDefense: Int(playerTokiCD.currentDefense),
            currentSpeed: Int(playerTokiCD.currentSpeed)
        )
    }
}
