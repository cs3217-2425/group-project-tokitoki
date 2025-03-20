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
            print("GachaService: No pack found with ID \(packId)")
            return []
        }

        let newPlayerTokis: [PlayerToki] = pack.containedTokis.compactMap { baseToki in
            // Fetch TokiCD from Core Data by baseTokiID
            let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", baseToki.id as CVarArg)

            guard let baseTokiCD = try? context.fetch(fetchRequest).first else {
                print("GachaService: Could not find base TokiCD for ID \(baseToki.id)")
                return nil
            }

            // Create a new PlayerTokiCD with only a baseTokiID (no relationship)
            let playerTokiCD = PlayerTokiCD(context: context)
            playerTokiCD.id = UUID()
            playerTokiCD.baseTokiId = baseTokiCD.id  // Store only the UUID reference
            playerTokiCD.dateAcquired = Date()

            // Initialize stats from the base TokiCD
            playerTokiCD.currentHealth = baseTokiCD.baseHealth
            playerTokiCD.currentAttack = baseTokiCD.baseAttack
            playerTokiCD.currentDefense = baseTokiCD.baseDefense
            playerTokiCD.currentSpeed = baseTokiCD.baseSpeed

            return PlayerToki(
                id: playerTokiCD.id!,
                baseTokiId: playerTokiCD.baseTokiId!,
                dateAcquired: playerTokiCD.dateAcquired!,
                currentHealth: Int(playerTokiCD.currentHealth),
                currentAttack: Int(playerTokiCD.currentAttack),
                currentDefense: Int(playerTokiCD.currentDefense),
                currentSpeed: Int(playerTokiCD.currentSpeed)
            )
        }

        // Save the new PlayerTokiCD instances
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving PlayerTokiCD: \(error)")
            }
        }

        // Append the newly acquired Tokis to the player
        player.ownedTokis.append(contentsOf: newPlayerTokis)
        return newPlayerTokis
    }
    
    private func randomRarity(from distribution: [TokiRarity: Double]) -> TokiRarity {
        let roll = Double.random(in: 0.0...1.0)
        var cumulative = 0.0
        
        // Sort by key or just iterate. Make sure the sum is ~1.0
        for (rarity, rate) in distribution {
            cumulative += rate
            if roll <= cumulative {
                return rarity
            }
        }
        return .common // fallback if floating-point rounding
    }
}
