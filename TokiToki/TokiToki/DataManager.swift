//
//  DataManager.swift
//  TokiToki
//
//  Created by wesho on 19/3/25.
//

import CoreData
import Foundation

// Serves as central access point for Core Data operations
class DataManager {
    // MARK: - Shared Instance (Singleton)
    static let shared = DataManager()

    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TokiToki")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // Make init private to enforce singleton pattern
    private init() {}

    // MARK: - Core Data Saving Support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Context saved successfully")
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Generic Fetch Methods
    func fetch<T: NSManagedObject>(_ entityType: T.Type, predicate: NSPredicate? = nil,
                                   sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let entityName = String(describing: entityType)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)

        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching \(entityName): \(error)")
            return []
        }
    }

    func fetchOne<T: NSManagedObject>(_ entityType: T.Type, predicate: NSPredicate) -> T? {
        let entityName = String(describing: entityType)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)

        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching single \(entityName): \(error)")
            return nil
        }
    }

    // MARK: - Create and Delete Methods
    func createEntity<T: NSManagedObject>(_ entityType: T.Type) -> T? {
        let entityName = String(describing: entityType)

        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: viewContext) else {
            print("Error: Could not find entity description for \(entityName)")
            return nil
        }

        let entity = NSManagedObject(entity: entityDescription, insertInto: viewContext)

        if let typedEntity = entity as? T {
            return typedEntity
        } else {
            print("Error: Could not cast entity to \(entityName)")
            viewContext.delete(entity)
            return nil
        }
    }

    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        saveContext()
    }

    // MARK: - Transaction Support
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            block(context)

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error saving background context: \(error)")
                }
            }
        }
    }
}
