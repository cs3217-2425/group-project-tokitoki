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
    private let context: NSManagedObjectContext
    private var gachaPacks: [String: GachaPack] = [:]  // Using name as key instead of UUID
    
    init(itemRepository: ItemRepository, eventService: EventService, context: NSManagedObjectContext) {
        self.itemRepository = itemRepository
        self.eventService = eventService
        self.context = context
        
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
                    var item: (any IGachaItem)?
                    
                    switch itemData.itemType {
                    case "toki":
                        item = itemRepository.getTokiTemplate(name: itemName)
                    case "skill":
                        item = itemRepository.getSkillTemplate(name: itemName)
                    case "equipment":
                        item = itemRepository.getEquipmentTemplate(name: itemName)
                    default:
                        continue
                    }
                    
                    if let item = item {
                        let packItem = GachaPackItem(item: item, itemName: itemName, baseRate: baseRate)
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
        return gachaPacks[name]
    }
    
    // Get all available packs
    func getAllPacks() -> [GachaPack] {
        return Array(gachaPacks.values)
    }
    
    // Pull from a gacha pack
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
            if let template = drawSingleItem(from: pack, with: rateModifiers, for: &player) {
                // Create player-specific instance from the template
                if let tokiTemplate = template as? Toki {
                    let playerToki = itemRepository.createPlayerItems(from: tokiTemplate, ownerId: player.id)
                    player.ownedTokis.append(playerToki)
                    drawnItems.append(playerToki)
                }
                // Note: We could also handle skill-only or equipment-only gacha draws here
            }
        }
        
        // Deduct currency
        _ = player.spendCurrency(totalCost)
        
        return drawnItems
    }
    
    // Draw a single item template with rate modifiers applied
    private func drawSingleItem(from pack: GachaPack, with rateModifiers: [String: Double], for player: inout Player) -> (any IGachaItem)? {
        // Create a probability distribution with modified rates
        var totalWeight: Double = 0
        var weightedItems: [(item: any IGachaItem, weight: Double)] = []
        
        for packItem in pack.items {
            let item = packItem.item
            let itemName = packItem.itemName
            var rate = packItem.baseRate
            
            // Apply rate modifier if there's one for this item by name
            if let modifier = rateModifiers[itemName] {
                rate *= modifier
            }
            
            // Apply pity system for rare items
            if isRare(item) && player.pullsSinceRare >= 100 {
                rate *= 5.0 // Significant boost for pity
            }
            
            weightedItems.append((item: item, weight: rate))
            totalWeight += rate
        }
        
        // Normalize weights if needed
        if totalWeight > 1.0 {
            weightedItems = weightedItems.map { (item: $0.item, weight: $0.weight / totalWeight) }
            totalWeight = 1.0
        }
        
        // Roll and select an item
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
        
        // Fallback if distribution is empty or no item selected
        return pack.items.first?.item
    }
    
    // Check if item is considered "rare" for pity system
    private func isRare(_ item: any IGachaItem) -> Bool {
        return item.rarity == .rare || item.rarity == .legendary
    }
}
