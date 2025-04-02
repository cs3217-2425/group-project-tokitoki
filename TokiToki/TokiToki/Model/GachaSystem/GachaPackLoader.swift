//
//  GachaPackLoader.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 21/3/25.
//

import CoreData
import Foundation

class GachaPackLoader {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func loadGachaPacks(from filename: String) throws {
        let gachaPacksData: GachaPacksData = try ResourceLoader.loadJSON(fromFile: filename)

        for packData in gachaPacksData.packs {
            if let existing = fetchPackByName(packData.packName) {
                print("Skipping creation: GachaPack '\(packData.packName)' already exists in Core Data.")
                continue
            }

            let gachaPackCD = GachaPackCD(context: context)
            gachaPackCD.id = UUID()
            gachaPackCD.name = packData.packName

            let tokiCDs = fetchTokiCDsByNames(packData.tokiNames)
            gachaPackCD.tokis = NSSet(array: tokiCDs)

            if let rates = packData.rarityDropRates {
                gachaPackCD.rarityDropRates = rates as NSDictionary
            } else {
                gachaPackCD.rarityDropRates = NSDictionary()
            }
        }

        if context.hasChanges {
            do {
                try context.save()
                print("Successfully loaded/updated Gacha Packs from \(filename).json.")
            } catch {
                print("Error saving GachaPackCD: \(error)")
            }
        }
    }

    private func fetchPackByName(_ name: String) -> GachaPackCD? {
        let fetchRequest: NSFetchRequest<GachaPackCD> = GachaPackCD.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching GachaPackCD by name \(name): \(error)")
            return nil
        }
    }

    private func fetchTokiCDsByNames(_ names: [String]) -> [TokiCD] {
        guard !names.isEmpty else { return [] }

        let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name IN %@", names)

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching TokiCD by names \(names): \(error)")
            return []
        }
    }
}
