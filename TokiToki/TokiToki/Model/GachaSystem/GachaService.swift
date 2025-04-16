//
//  GachaService.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import Foundation
import CoreData

class GachaService {
    private let itemRepository: ItemRepository
    private let eventService: EventService
    private var gachaPacks: [String: GachaPack] = [:]

    init(itemRepository: ItemRepository, eventService: EventService) {
        self.itemRepository = itemRepository
        self.eventService = eventService
        loadGachaPacks()
        
    }

    // Load gacha packs directly from JSON
    private func loadGachaPacks() {
        do {
            let packsData: GachaPacksData = try ResourceLoader.loadJSON(fromFile: "GachaPacks")

            for packData in packsData.packs {
                var packItems: [GachaPackItem] = []

                // Process each item in the pack
                for itemData in packData.items {
                    let itemName = itemData.itemId
                    let baseRate = itemData.baseRate

                    // Find the template based on item type and name
                    var gachaItem: (any IGachaItem)?

                    switch itemData.itemType {
                    case "toki":
                        if let toki = itemRepository.getTokiTemplate(name: itemName) {
                            let createdToki = itemRepository.createToki(from: toki)
                            gachaItem = GachaItemFactory.createTokiGachaItem(toki: createdToki)
                        }
                    case "equipment":
                        if let equipment = itemRepository.getEquipmentTemplate(name: itemName) {
                            let createdEquipment = itemRepository.createEquipment(from: equipment)
                            let elementType = itemData.elementType != nil ?
                                convertStringToElementType(itemData.elementType!) : .neutral
                            gachaItem = GachaItemFactory.createEquipmentGachaItem(equipment: createdEquipment, elementType: elementType)
                        }
                    default:
                        continue
                    }

                    if let gachaItem = gachaItem {
                        let packItem = GachaPackItem(item: gachaItem, itemName: itemName, baseRate: baseRate)
                        packItems.append(packItem)
                    }
                }

                // Create gacha pack with name as identifier
                let gachaPack = GachaPack(
                    name: packData.packName,
                    description: packData.description,
                    cost: packData.cost,
                    items: packItems
                )

                gachaPacks[packData.packName] = gachaPack
            }

            print("Loaded \(gachaPacks.count) gacha packs from JSON")
        } catch {
            print("Error loading gacha packs: \(error)")
        }
    }

    // Find pack by name
    func findPack(byName name: String) -> GachaPack? {
        gachaPacks[name]
    }

    // Get all available packs
    func getAllPacks() -> [GachaPack] {
        Array(gachaPacks.values)
    }

    // Pull from a gacha pack (now just handles the draw logic, not player state)
    func drawFromPack(packName: String, count: Int, for player: inout Player) -> [any IGachaItem] {
        guard let pack = findPack(byName: packName) else {
            print("No pack found with name \(packName)")
            return []
        }

        // Check if player has enough currency
        let totalCost = pack.cost * count
        guard player.canSpendCurrency(totalCost) else {
            print("Player doesn't have enough currency to draw")
            return []
        }

        // Get event rate modifiers
        let rateModifiers = eventService.getRateModifiers(packName: packName)

        // Draw items
        var drawnItems: [any IGachaItem] = []
        for _ in 0..<count {
            if let drawnItem = drawSingleItem(from: pack, with: rateModifiers, for: &player) {
                var itemWithOwnership = drawnItem
                itemWithOwnership.ownerId = player.id
                itemWithOwnership.dateAcquired = Date()

                drawnItems.append(itemWithOwnership)

                // Add the drawn item to player's inventory
                // Note: This modifies the passed player reference
                if let tokiGachaItem = itemWithOwnership as? TokiGachaItem {
                    player.ownedTokis.append(tokiGachaItem.getToki())
                } else if let equipmentGachaItem = itemWithOwnership as? EquipmentGachaItem {
                    player.ownedEquipments.inventory.append(equipmentGachaItem.getEquipment())
                }
            }
        }

        // Deduct currency
        _ = player.spendCurrency(totalCost)

        // The modified player instance is returned via the inout parameter
        return drawnItems
    }

    // Draw a single item template with rate modifiers applied
    private func drawSingleItem(from pack: GachaPack, with rateModifiers: [String: Double], for player: inout Player) -> (any IGachaItem)? {
        var totalWeight: Double = 0
        var weightedItems: [(item: any IGachaItem, weight: Double)] = []

        for packItem in pack.items {
            let item = packItem.item
            let itemName = packItem.itemName
            var rate = packItem.baseRate

            if let modifier = rateModifiers[itemName] {
                rate *= modifier
            }

            // Apply pity system for rare items
            if isRare(item) && player.pullsSinceRare >= 20 {
                rate *= 5.0 // Significant boost for pity
            }

            if rate > 0 {
                weightedItems.append((item: item, weight: rate))
                totalWeight += rate
            }
        }

        guard !weightedItems.isEmpty, totalWeight > 0 else {
            print("No valid items in pack or all rates are zero")
            return pack.items.first?.item
        }

        if totalWeight > 1.0 {
            weightedItems = weightedItems.map { (item: $0.item, weight: $0.weight / totalWeight) }
            totalWeight = 1.0
        }

        let roll = Double.random(in: 0..<totalWeight)
        var cumulativeWeight: Double = 0

        for (item, weight) in weightedItems {
            cumulativeWeight += weight
            if roll < cumulativeWeight {
                // Update pity counter
                if isRare(item) {
                    player.pullsSinceRare = 0
                } else {
                    player.pullsSinceRare += 1
                }

                return item
            }
        }

        return weightedItems.first?.item
    }

    // Check if item is considered "rare" for pity system
    private func isRare(_ item: any IGachaItem) -> Bool {
        item.rarity == .rare || item.rarity == .epic
    }

    // Helper methods
    private func convertIntToItemRarity(_ value: Int) -> ItemRarity {
        switch value {
        case 0: return .common
        case 1: return .rare
        case 2: return .epic
        default: return .common
        }
    }

    private func convertStringToElementType(_ str: String) -> ElementType {
        switch str.lowercased() {
        case "fire": return .fire
        case "water": return .water
        case "earth": return .earth
        case "air": return .air
        case "light": return .light
        default: return .neutral
        }
    }
}
