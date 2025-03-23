//
//  TokiLoader.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import Foundation
import CoreData

class TokiLoader {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func loadTokis(from filename: String) throws {
        
        let tokisData: TokisData = try ResourceLoader.loadJSON(fromFile: filename)

        for tokiData in tokisData.tokis {
            let existing = fetchTokiByName(tokiData.name)
            if existing != nil {
                print("Skipping creation: Toki '\(tokiData.name)' already exists in Core Data.")
                continue
            }
            
            let tokiCD = TokiCD(context: context)
            tokiCD.id = UUID()
            tokiCD.name = tokiData.name
            tokiCD.rarity = Int16(tokiData.rarity)
            tokiCD.baseHealth = Int16(tokiData.baseHealth)
            tokiCD.baseAttack = Int16(tokiData.baseAttack)
            tokiCD.baseDefense = Int16(tokiData.baseDefense)
            tokiCD.baseSpeed = Int16(tokiData.baseSpeed)
            tokiCD.baseHeal = Int16(tokiData.baseHeal)
            tokiCD.baseExp = Int16(tokiData.baseExp)
            tokiCD.elementType = tokiData.elementType
        }

        if context.hasChanges {
            do {
                try context.save()
                print("Successfully loaded/updated Tokis from \(filename).json into Core Data.")
            } catch {
                print("Error saving Tokis: \(error)")
            }
        }
    }
    
    private func fetchTokiByName(_ name: String) -> TokiCD? {
        let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching Toki by name \(name): \(error)")
            return nil
        }
    }
}

