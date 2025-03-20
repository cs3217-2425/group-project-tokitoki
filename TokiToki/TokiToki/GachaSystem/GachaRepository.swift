//
//  GachaRepository.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import Foundation
import CoreData

class GachaRepository {
    
    var allTokis: [Toki] = []
    var gachaPacks: [GachaPack] = []
    
    // Public method for the rest of the app
    // 1) Seeds JSON if needed
    // 2) Loads from Core Data into domain arrays
    func initializeData(context: NSManagedObjectContext) {
        seedIfNeeded(context: context)
        loadFromCoreData(context: context)
    }
    
    // Check if TokiCD or GachaPackCD are empty; if so, load from JSON
    private func seedIfNeeded(context: NSManagedObjectContext) {
        do {
            // 1) Check TokiCD
            let tokiFetch: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
            let tokiCount = try context.count(for: tokiFetch)
            
            // 2) Check GachaPackCD
            let packFetch: NSFetchRequest<GachaPackCD> = GachaPackCD.fetchRequest()
            let packCount = try context.count(for: packFetch)
            
            if tokiCount == 0 || packCount == 0 {
                print("No Toki or GachaPack data found in Core Data. Seeding from JSON...")

                // Use your TokiLoader and GachaPackLoader to load from JSON
                let tokiLoader = TokiLoader(context: context)
                try? tokiLoader.loadTokis(from: "Tokis")     // e.g. "Tokis.json"
                print("Loaded Tokis")
                
                let packLoader = GachaPackLoader(context: context)
                try? packLoader.loadGachaPacks(from: "GachaPacks") // e.g. "GachaPacks.json"
            } else {
                print("Toki and GachaPack data already exist. No seeding needed.")
            }
        } catch {
            print("Error checking Toki/GachaPack data count: \(error)")
        }
    }
    
    // Fetch TokiCD/GachaPackCD from Core Data and convert to domain objects
    private func loadFromCoreData(context: NSManagedObjectContext) {
        // 1) Fetch TokiCD -> domain Toki
        do {
            let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
            let results = try context.fetch(fetchRequest)
            
            let domainTokis = results.map { cd -> Toki in
                Toki(
                    id: cd.id ?? UUID(),
                    name: cd.name ?? "Unknown",
                    rarity: convertIntToRarity(cd.rarity),
                    baseStats: TokiBaseStats(
                        health: Int(cd.baseHealth),
                        attack: Int(cd.baseAttack),
                        defense: Int(cd.baseDefense),
                        speed: Int(cd.baseSpeed)
                    ),
                    skills: [],
                    elementType: convertStringToElement(cd.elementType ?? "fire")
                )
            }
            self.allTokis = domainTokis
        } catch {
            print("Error fetching TokiCD: \(error)")
        }
        
        // 2) Fetch GachaPackCD -> domain GachaPack
        do {
            let packFetch: NSFetchRequest<GachaPackCD> = GachaPackCD.fetchRequest()
            let packResults = try context.fetch(packFetch)
            
            let domainPacks = packResults.map { packCD -> GachaPack in
                let tokisSet = (packCD.tokis as? Set<TokiCD>) ?? []
                
                let domainTokis = tokisSet.compactMap { tokiCD in
                    self.allTokis.first(where: { $0.id == tokiCD.id })
                }
                
                return GachaPack(
                    id: packCD.id ?? UUID(),
                    name: packCD.name ?? "Unnamed Pack",
                    containedTokis: domainTokis
                )
            }
            
            self.gachaPacks = domainPacks
        } catch {
            print("Error fetching GachaPackCD: \(error)")
        }
    }
    
    // A simple method to find a pack by ID if you need it
    func findPack(by id: UUID) -> GachaPack? {
        return gachaPacks.first { $0.id == id }
    }
    
    // MARK: - Helper Conversions
    private func convertIntToRarity(_ value: Int16) -> TokiRarity {
        switch value {
        case 0: return .common
        case 1: return .uncommon
        case 2: return .rare
        case 3: return .epic
        case 4: return .legendary
        default: return .common
        }
    }

    private func convertStringToElement(_ str: String) -> ElementType {
        switch str.lowercased() {
        case "fire": return .fire
        case "water": return .water
        case "earth": return .earth
        case "air":   return .air
        default: return .fire
        }
    }
}

