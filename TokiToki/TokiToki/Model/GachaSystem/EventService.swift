//
//  EventService.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//

import Foundation
import CoreData

protocol EventServiceProtocol {
    func getActiveEvents() -> [any IGachaEvent]
    func getEvent(name: String) -> (any IGachaEvent)?
    func getRateModifiers(packName: String) -> [String: Double]
    func addEvent(_ event: any IGachaEvent)
    func removeEvent(name: String)
}

class EventService: EventServiceProtocol {
    // MARK: - Properties

    private var events: [String: any IGachaEvent] = [:]  // Using name as the key
    private let tokiFactory: TokiFactoryProtocol
    private let equipmentFactory: EquipmentFactoryProtocol
    private let logger = Logger(subsystem: "EventService")

    // MARK: - Initialization

    init(tokiFactory: TokiFactoryProtocol,
         equipmentFactory: EquipmentFactoryProtocol
         ) {
        self.tokiFactory = tokiFactory
        self.equipmentFactory = equipmentFactory

        logger.log("LOADING EVENTS")
        loadEvents()

        // Log active events
        let activeEvents = getActiveEvents()
        logger.log("Active Gacha Events:")
        for event in activeEvents {
            logger.log("\(event.name): \(event.description) (from \(event.startDate) to \(event.endDate))")
        }
    }

    // MARK: - Public Methods

    /// Get all active events
    func getActiveEvents() -> [any IGachaEvent] {
        events.values.filter { $0.isActive }
    }

    /// Get event by name
    func getEvent(name: String) -> (any IGachaEvent)? {
        events[name]
    }

    /// Get rate modifiers from all active events for a given gacha pack
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

    /// Add a new event
    func addEvent(_ event: any IGachaEvent) {
        events[event.name] = event
    }

    /// Remove an event
    func removeEvent(name: String) {
        events.removeValue(forKey: name)
    }

    // MARK: - Private Methods

    /// Load events from JSON and create appropriate event objects
    private func loadEvents() {
        do {
            let eventsData: EventsData = try ResourceLoader.loadJSON(fromFile: "Events")

            for eventData in eventsData.events {
                if let event = createEventFromData(eventData) {
                    events[eventData.name] = event
                }
            }

            logger.log("Loaded \(events.count) events")
        } catch {
            logger.logError("Error loading events: \(error)")
        }
    }

    private func createEventFromData(_ eventData: EventData) -> (any IGachaEvent)? {
        let dateFormatter = ISO8601DateFormatter()

        guard let startDate = dateFormatter.date(from: eventData.startDate),
              let endDate = dateFormatter.date(from: eventData.endDate) else {
            logger.logError("Invalid date format for event: \(eventData.name)")
            return nil
        }

        switch eventData.eventType.lowercased() {
        case "element":
            return createElementEvent(eventData, startDate, endDate)
        case "item":
            return createItemBoostEvent(eventData, startDate, endDate)
        default:
            logger.log("Unknown event type: \(eventData.eventType)")
            return nil
        }
    }

    private func createElementEvent(_ eventData: EventData, _ startDate: Date, _ endDate: Date) -> ElementEvent? {
        guard let elementTypeStr = eventData.targetElement,
              let elementType = ElementType.fromString(elementTypeStr) else {
            logger.logError("Invalid element type for event: \(eventData.name)")
            return nil
        }

        return ElementEvent(
            name: eventData.name,
            description: eventData.description,
            startDate: startDate,
            endDate: endDate,
            elementType: elementType,
            rateMultiplier: eventData.rateMultiplier,
            tokiFactory: tokiFactory,
            equipmentFactory: equipmentFactory
        )
    }

    private func createItemBoostEvent(_ eventData: EventData, _ startDate: Date, _ endDate: Date) -> ItemBoostEvent? {
        guard let targetItemNames = eventData.targetItemNames else {
            logger.logError("No item names specified for item boost event: \(eventData.name)")
            return nil
        }

        return ItemBoostEvent(
            name: eventData.name,
            description: eventData.description,
            startDate: startDate,
            endDate: endDate,
            targetItemNames: targetItemNames,
            rateMultiplier: eventData.rateMultiplier
        )
    }
}
