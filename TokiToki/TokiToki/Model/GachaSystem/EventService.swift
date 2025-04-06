//
//  EventService.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//

import Foundation
import CoreData

class EventService {
    private var events: [String: any IGachaEvent] = [:]  // Using name as the key
    private let itemRepository: ItemRepository
    private let context: NSManagedObjectContext

    init(itemRepository: ItemRepository, context: NSManagedObjectContext) {
        self.itemRepository = itemRepository
        self.context = context

        loadEvents()
    }

    // Load events from JSON and create appropriate event objects
    private func loadEvents() {
        do {
            let eventsData: EventsData = try ResourceLoader.loadJSON(fromFile: "Events")

            for eventData in eventsData.events {
                let dateFormatter = ISO8601DateFormatter()

                guard let startDate = dateFormatter.date(from: eventData.startDate),
                      let endDate = dateFormatter.date(from: eventData.endDate) else {
                    print("Invalid date format for event: \(eventData.name)")
                    continue
                }

                let event: any IGachaEvent

                switch eventData.eventType.lowercased() {
                case "element":
                    guard let elementTypeStr = eventData.targetElement,
                          let elementType = ElementType(rawValue: elementTypeStr.lowercased()) else {
                        print("Invalid element type for event: \(eventData.name)")
                        continue
                    }

                    event = ElementEvent(
                        name: eventData.name,
                        description: eventData.description,
                        startDate: startDate,
                        endDate: endDate,
                        elementType: elementType,
                        rateMultiplier: eventData.rateMultiplier,
                        itemRepository: itemRepository
                    )

                case "item":
                    guard let targetItemNames = eventData.targetItemNames else {
                        print("No item names specified for item boost event: \(eventData.name)")
                        continue
                    }

                    event = ItemBoostEvent(
                        name: eventData.name,
                        description: eventData.description,
                        startDate: startDate,
                        endDate: endDate,
                        targetItemNames: targetItemNames,
                        rateMultiplier: eventData.rateMultiplier
                    )

                default:
                    print("Unknown event type: \(eventData.eventType)")
                    continue
                }

                events[eventData.name] = event
            }

            print("Loaded \(events.count) events")

        } catch {
            print("Error loading events: \(error)")
        }
    }

    // Get all active events
    func getActiveEvents() -> [any IGachaEvent] {
        events.values.filter { $0.isActive }
    }

    // Get event by name
    func getEvent(name: String) -> (any IGachaEvent)? {
        events[name]
    }

    // Get rate modifiers from all active events for a given gacha pack
    func getRateModifiers(packName: String) -> [String: Double] {
        var combinedModifiers: [String: Double] = [:]

        // Collect modifiers from all active events
        for event in getActiveEvents() {
            let modifiers = event.getRateModifiers()

            // Combine modifiers, using the highest value if multiple events affect the same item
            for (itemName, multiplier) in modifiers {
                if let existingMultiplier = combinedModifiers[itemName] {
                    combinedModifiers[itemName] = max(existingMultiplier, multiplier)
                } else {
                    combinedModifiers[itemName] = multiplier
                }
            }
        }

        return combinedModifiers
    }

    // Add a new event
    func addEvent(_ event: any IGachaEvent) {
        events[event.name] = event
    }

    // Remove an event
    func removeEvent(name: String) {
        events.removeValue(forKey: name)
    }
}
