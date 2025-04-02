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

    func initializeData(context: NSManagedObjectContext) {
        seedIfNeeded(context: context)
        loadFromCoreData(context: context)
    }

    private func seedIfNeeded(context: NSManagedObjectContext) {
        do {
            let tokiFetch: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
            let tokiCount = try context.count(for: tokiFetch)

            let packFetch: NSFetchRequest<GachaPackCD> = GachaPackCD.fetchRequest()
            let packCount = try context.count(for: packFetch)

            if tokiCount == 0 || packCount == 0 {

                let tokiLoader = TokiLoader(context: context)
                try? tokiLoader.loadTokis(from: "Tokis")

                let packLoader = GachaPackLoader(context: context)
                try? packLoader.loadGachaPacks(from: "GachaPacks")
            } else {
                print("Toki and GachaPack data already exist. No seeding needed.")
            }
        } catch {
            print("Error checking Toki/GachaPack data count: \(error)")
        }
    }

    private func loadFromCoreData(context: NSManagedObjectContext) {
        do {
            let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
            let results = try context.fetch(fetchRequest)

            let domainTokis = results.map { cd -> Toki in
                Toki(
                    id: cd.id ?? UUID(),
                    name: cd.name ?? "Unknown",
                    rarity: convertIntToRarity(cd.rarity),
                    baseStats: TokiBaseStats(
                        hp: Int(cd.baseHealth),
                        attack: Int(cd.baseAttack),
                        defense: Int(cd.baseDefense),
                        speed: Int(cd.baseSpeed),
                        heal: Int(cd.baseHeal),
                        exp: Int(cd.baseExp)
                    ),
                    skills: [],
                    equipments: [],
                    elementType: [convertStringToElement(cd.elementType ?? "fire")],
                    level: 0
                )
            }
            self.allTokis = domainTokis
        } catch {
            print("Error fetching TokiCD: \(error)")
        }

        do {
            let packFetch: NSFetchRequest<GachaPackCD> = GachaPackCD.fetchRequest()
            let packResults = try context.fetch(packFetch)

            let domainPacks = packResults.map { packCD -> GachaPack in
                let tokisSet = (packCD.tokis as? Set<TokiCD>) ?? []

                let domainTokis = tokisSet.compactMap { tokiCD in
                    self.allTokis.first(where: { $0.id == tokiCD.id })
                }

                var rarityRates: [TokiRarity: Double] = [:]
                if let storedDict = packCD.rarityDropRates as? [String: Double] {
                    for (rarityStr, probability) in storedDict {
                        if let rarity = TokiRarity(rawValue: rarityStr) {
                            rarityRates[rarity] = probability
                        }
                    }
                }

                return GachaPack(
                    id: packCD.id ?? UUID(),
                    name: packCD.name ?? "Unnamed Pack",
                    containedTokis: domainTokis,
                    rarityDropRates: rarityRates
                )
            }

            self.gachaPacks = domainPacks
        } catch {
            print("Error fetching GachaPackCD: \(error)")
        }
    }

    func findPack(by id: UUID) -> GachaPack? {
        gachaPacks.first { $0.id == id }
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
