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
        container.loadPersistentStores { _, error in
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
    
    /// Save the main view context
    func saveContext() {
        saveContext(viewContext)
    }
    
    /// Save a specific managed object context
    func saveContext(_ context: NSManagedObjectContext) {
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
                                   sortDescriptors: [NSSortDescriptor]? = nil,
                                   context: NSManagedObjectContext? = nil) -> [T] {
        // Use provided context or default to view context
        let ctx = context ?? viewContext
        
        let entityName = String(describing: entityType)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)

        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors

        do {
            return try ctx.fetch(fetchRequest)
        } catch {
            print("Error fetching \(entityName): \(error)")
            return []
        }
    }

    func fetchOne<T: NSManagedObject>(_ entityType: T.Type, predicate: NSPredicate,
                                      context: NSManagedObjectContext? = nil) -> T? {
        // Use provided context or default to view context
        let ctx = context ?? viewContext
        
        let entityName = String(describing: entityType)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)

        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        do {
            let results = try ctx.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching single \(entityName): \(error)")
            return nil
        }
    }

    // MARK: - Create and Delete Methods
    func createEntity<T: NSManagedObject>(_ entityType: T.Type,
                                          context: NSManagedObjectContext? = nil) -> T? {
        // Use provided context or default to view context
        let ctx = context ?? viewContext
        
        let entityName = String(describing: entityType)

        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: ctx) else {
            print("Error: Could not find entity description for \(entityName)")
            return nil
        }

        let entity = NSManagedObject(entity: entityDescription, insertInto: ctx)

        if let typedEntity = entity as? T {
            return typedEntity
        } else {
            print("Error: Could not cast entity to \(entityName)")
            ctx.delete(entity)
            return nil
        }
    }

    func delete(_ object: NSManagedObject, context: NSManagedObjectContext? = nil) {
        // Use provided context or default to view context
        let ctx = context ?? viewContext
        
        ctx.delete(object)
        saveContext(ctx)
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
    
    // MARK: - Context Creation
    
    /// Create a new background context for operations that should not block the UI
    func createBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
