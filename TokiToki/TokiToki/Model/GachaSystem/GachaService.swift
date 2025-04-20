//
//  GachaService.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import Foundation
import CoreData

protocol GachaServiceProtocol {
    func findPack(byName name: String) -> GachaPack?
    func getAllPacks() -> [GachaPack]
    func drawFromPack(packName: String, count: Int, for player: inout Player) -> [any IGachaItem]
}

class GachaService: GachaServiceProtocol {
    // MARK: - Properties
    
    private let tokiFactory: TokiFactoryProtocol
    private let equipmentFactory: EquipmentFactoryProtocol
    private let skillsFactory: SkillsFactoryProtocol
    private let eventService: EventServiceProtocol
    private var gachaPacks: [String: GachaPack] = [:]
    private let logger = Logger(subsystem: "GachaService")
    
    // MARK: - Initialization
    
    init(tokiFactory: TokiFactoryProtocol,
         equipmentFactory: EquipmentFactoryProtocol,
         skillsFactory: SkillsFactoryProtocol,
         eventService: EventServiceProtocol) {
        self.tokiFactory = tokiFactory
        self.equipmentFactory = equipmentFactory
        self.skillsFactory = skillsFactory
        self.eventService = eventService
        loadGachaPacks()
    }
    
    // MARK: - Public Methods
    
    /// Find a gacha pack by name
    func findPack(byName name: String) -> GachaPack? {
        return gachaPacks[name]
    }
    
    /// Get all available gacha packs
    func getAllPacks() -> [GachaPack] {
        return Array(gachaPacks.values)
    }
    
    /// Draw items from a gacha pack
    /// - Parameters:
    ///   - packName: Name of the pack to draw from
    ///   - count: Number of draws to perform
    ///   - player: Player who is drawing (will be modified to reflect currency changes, etc.)
    /// - Returns: Array of drawn items
    func drawFromPack(packName: String, count: Int, for player: inout Player) -> [any IGachaItem] {
        guard let pack = findPack(byName: packName) else {
            logger.log("No pack found with name \(packName)")
            return []
        }
        
        // Check if player has enough currency
        let totalCost = pack.cost * count
        guard player.canSpendCurrency(totalCost) else {
            logger.log("Player doesn't have enough currency to draw")
            return []
        }
        
        // Get event rate modifiers
        let rateModifiers = eventService.getRateModifiers(packName: packName)
        
        // Draw items
        var drawnItems: [any IGachaItem] = []
        for _ in 0..<count {
            if let drawnItem = drawSingleItem(from: pack, with: rateModifiers, for: &player) {
                // Set ownership metadata
                var itemWithOwnership = drawnItem
                itemWithOwnership.ownerId = player.id
                itemWithOwnership.dateAcquired = Date()
                
                drawnItems.append(itemWithOwnership)
                
                // Add the drawn item to player's inventory
                addItemToPlayerInventory(item: itemWithOwnership, for: &player)
            }
        }
        
        // Deduct currency
        _ = player.spendCurrency(totalCost)
        
        return drawnItems
    }
    
    // MARK: - Private Methods
    
    /// Load gacha packs from JSON
    private func loadGachaPacks() {
        do {
            let packsData: GachaPacksData = try ResourceLoader.loadJSON(fromFile: "GachaPacks")
            
            for packData in packsData.packs {
                let packItems = createPackItems(from: packData.items)
                
                // Create gacha pack
                let gachaPack = GachaPack(
                    name: packData.packName,
                    description: packData.description,
                    cost: packData.cost,
                    items: packItems
                )
                
                gachaPacks[packData.packName] = gachaPack
            }
            
            logger.log("Loaded \(gachaPacks.count) gacha packs from JSON")
        } catch {
            logger.log("Error loading gacha packs: \(error)")
        }
    }
    
    /// Create pack items from item data
    private func createPackItems(from itemsData: [GachaItemData]) -> [GachaPackItem] {
        return itemsData.compactMap { itemData in
            let itemName = itemData.itemId
            let baseRate = itemData.baseRate

            guard let itemType = GachaItemType.fromString(itemData.itemType) else {
                logger.logError("Unknown item type: \(itemData.itemType)")
                return nil
            }

            var gachaItem: (any IGachaItem)?

            switch itemType {
            case .toki:
                if let tokiTemplate = tokiFactory.getTemplate(named: itemName) {
                    gachaItem = GachaItemFactory.createTokiGachaItem(template: tokiTemplate, factory: tokiFactory)
                }
            case .equipment:
                if let equipmentTemplate = equipmentFactory.getTemplate(named: itemName) {
                    gachaItem = GachaItemFactory.createEquipmentGachaItem(template: equipmentTemplate, factory: equipmentFactory)
                }
            }

            guard let item = gachaItem else { return nil }
            return GachaPackItem(item: item, itemName: itemName, baseRate: baseRate)
        }
    }
    
    /// Draw a single item with rate modifiers applied
    private func drawSingleItem(
        from pack: GachaPack,
        with rateModifiers: [String: Double],
        for player: inout Player
    ) -> (any IGachaItem)? {
        // Build weighted items array
        let weightedItems = buildWeightedItems(from: pack, with: rateModifiers, for: player)
        
        guard !weightedItems.isEmpty else {
            logger.logError("No valid items in pack or all rates are zero")
            return pack.items.first?.item
        }
        
        let totalWeight = weightedItems.reduce(0) { $0 + $1.weight }
        
        // Normalize weights if they sum to more than 1.0
        let normalizedItems = totalWeight > 1.0 ?
            weightedItems.map { (item: $0.item, weight: $0.weight / totalWeight) } :
            weightedItems
        
        // Perform the roll
        let roll = Double.random(in: 0..<min(totalWeight, 1.0))
        var cumulativeWeight: Double = 0
        
        for (item, weight) in normalizedItems {
            cumulativeWeight += weight
            if roll < cumulativeWeight {
                // Update pity counter
                updatePityCounter(for: item, player: &player)
                return item
            }
        }
        
        return normalizedItems.first?.item
    }
    
    /// Build weighted items for the gacha roll
    private func buildWeightedItems(
        from pack: GachaPack,
        with rateModifiers: [String: Double],
        for player: Player
    ) -> [(item: any IGachaItem, weight: Double)] {
        var weightedItems: [(item: any IGachaItem, weight: Double)] = []
        
        for packItem in pack.items {
            let item = packItem.item
            let itemName = packItem.itemName
            var rate = packItem.baseRate
            
            // Apply event modifiers
            if let modifier = rateModifiers[itemName] {
                rate *= modifier
            }
            
            // Apply pity system for rare items
            if isRare(item) && player.pullsSinceRare >= 20 {
                rate *= 5.0 // Significant boost for pity
            }
            
            if rate > 0 {
                weightedItems.append((item: item, weight: rate))
            }
        }
        
        return weightedItems
    }
    
    /// Update the pity counter based on the drawn item
    private func updatePityCounter(for item: any IGachaItem, player: inout Player) {
        if isRare(item) {
            player.pullsSinceRare = 0
        } else {
            player.pullsSinceRare += 1
        }
    }
    
    /// Add an item to the player's inventory
    private func addItemToPlayerInventory(item: any IGachaItem, for player: inout Player) {
        switch item {
        case let tokiAdapter as TokiGachaItem:
            if let toki = tokiAdapter.createInstance() as? Toki,
               !player.ownedTokis.contains(where: { $0.name == toki.name }) {
                player.ownedTokis.append(toki)
            }

        case let eqAdapter as EquipmentGachaItem:
            if let equipment = eqAdapter.createInstance() as? Equipment,
               !player.ownedEquipments.inventory.contains(where: { $0.name == equipment.name }) {
                player.ownedEquipments.inventory.append(equipment)
            }

        default:
            logger.logError("Unknown gacha adapter type")
        }
    }

    
    /// Check if an item is considered "rare" for pity system
    private func isRare(_ item: any IGachaItem) -> Bool {
        return item.rarity == .rare || item.rarity == .epic
    }
}
