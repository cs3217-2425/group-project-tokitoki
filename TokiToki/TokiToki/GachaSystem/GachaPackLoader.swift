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
        print("Loading Gacha Packs from \(filename).json")
        
        // 1) Decode the entire GachaPacksData structure
        let gachaPacksData: GachaPacksData = try ResourceLoader.loadJSON(fromFile: filename)
        
        // 2) Iterate over each GachaPackData in the 'gachaPacks' array
        print("Number of Gacha Packs in JSON: \(gachaPacksData.packs.count)")
        for packData in gachaPacksData.packs {
            // Check if a GachaPackCD with the same name already exists
            let existing = fetchPackByName(packData.packName)
            if existing != nil {
                print("Skipping creation: GachaPack '\(packData.packName)' already exists in Core Data.")
                continue
            }
            
            // Create a new GachaPackCD record
            let gachaPackCD = GachaPackCD(context: context)
            gachaPackCD.id = UUID()
            gachaPackCD.name = packData.packName
            
            // Find Tokis by name
            let tokiCDs = fetchTokiCDsByNames(packData.tokiNames)
            gachaPackCD.tokis = NSSet(array: tokiCDs)
        }
        
        // 3) Save changes if we inserted/updated anything
        if context.hasChanges {
            do {
                try context.save()
                print("Successfully loaded/updated Gacha Packs from \(filename).json.")
            } catch {
                print("Error saving GachaPackCD: \(error)")
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func fetchPackByName(_ name: String) -> GachaPackCD? {
        let fetchRequest: NSFetchRequest<GachaPackCD> = GachaPackCD.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching GachaPack by name \(name): \(error)")
            return nil
        }
    }
    
    private func fetchTokiCDsByNames(_ names: [String]) -> [TokiCD] {
        guard !names.isEmpty else { return [] }
        
        let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name IN %@", names)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Error fetching TokiCD by names \(names): \(error)")
            return []
        }
    }
}

