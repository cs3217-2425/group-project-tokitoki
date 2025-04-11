//
//  JsonPersistanceManager.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 10/4/25.
//

import Foundation

class JsonPersistenceManager {
    
    // File names
    private let playersFileName = "players"
    private let playerTokisFileName = "player_tokis"
    private let playerEquipmentsFileName = "player_equipments"
    private let skillsFileName = "Skills"
    private var skillTemplates: [String: SkillData] = [:]
    private var skillsFactory: SkillsFactory = SkillsFactory()
    
    // JSON Encoder/Decoder
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .secondsSince1970
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        // Load skill templates
        loadSkillTemplates()
    }
    
    func loadSkillTemplates() {
        do {
            let skillsData: SkillsData = try ResourceLoader.loadJSON(fromFile: "Skills")
            
            for skillData in skillsData.skills {
                skillTemplates[skillData.name] = skillData
            }
        } catch {
            print("Error loading Skill templates: \(error)")
        }
    }
    
    func getSkillTemplate(name: String) -> SkillData? {
        skillTemplates[name]
    }
    
    // MARK: - Directory and File Handling
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getFileURL(filename: String) -> URL {
        getDocumentsDirectory().appendingPathComponent(filename).appendingPathExtension("json")
    }
    
    private func fileExists(filename: String) -> Bool {
        FileManager.default.fileExists(atPath: getFileURL(filename: filename).path)
    }
    
    // MARK: - Generic Read/Write Methods
    
    private func saveToJson<T: Encodable>(_ object: T, filename: String) -> Bool {
        do {
            let data = try encoder.encode(object)
            try data.write(to: getFileURL(filename: filename))
            return true
        } catch {
            print("Error saving \(filename).json: \(error)")
            return false
        }
    }
    
    private func loadFromJson<T: Decodable>(filename: String) -> T? {
        let fileURL = getFileURL(filename: filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Try loading from Bundle if it doesn’t exist in Documents
            guard let bundleURL = Bundle.main.url(forResource: filename, withExtension: "json") else {
                print("File \(filename).json not found in bundle")
                return nil
            }
            return loadDataFromURL(url: bundleURL)
        }
        
        return loadDataFromURL(url: fileURL)
    }
    
    func loadDataFromURL<T: Decodable>(url: URL) -> T? {
        do {
            let data = try Data(contentsOf: url)
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            print("Error loading \(url): \(error)")
            return nil
        }
    }
    
    func deleteJson(filename: String) -> Bool {
        let fileURL = getFileURL(filename: filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return true // File doesn't exist => "successful" deletion
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Successfully deleted \(filename).json")
            return true
        } catch {
            print("Error deleting \(filename).json: \(error)")
            return false
        }
    }
    
    // MARK: - Player Methods
    
    func savePlayers(_ players: [Player]) -> Bool {
        let playersCodable = players.map { PlayerCodable(from: $0) }
        return saveToJson(playersCodable, filename: playersFileName)
    }
    
    func savePlayer(_ player: Player) -> Bool {
        // 1) Load existing players
        var players: [PlayerCodable] = []
        if fileExists(filename: playersFileName),
           let existingPlayers: [PlayerCodable] = loadFromJson(filename: playersFileName) {
            players = existingPlayers
        }
        
        // 2) Convert the player to codable
        let playerCodable = PlayerCodable(from: player)
        
        // 3) Update or add
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = playerCodable
        } else {
            players.append(playerCodable)
        }
        
        // 4) Save all players
        let playersSaved = saveToJson(players, filename: playersFileName)
        
        // 5) Save player’s Tokis
        let tokisSaved = savePlayerTokis(player.ownedTokis, playerId: player.id)
        
        // [FIXED] 6) Save player's equipment
        let equipmentSaved = savePlayerEquipment(player.ownedEquipments, playerId: player.id)
        
        return playersSaved && tokisSaved && equipmentSaved
    }
    
    func loadPlayers() -> [Player]? {
        guard let playersCodable: [PlayerCodable] = loadFromJson(filename: playersFileName) else {
            return nil
        }
        
        var players: [Player] = []
        
        for playerCodable in playersCodable {
            var player = playerCodable.toDomainModel()
            
            // Load Tokis
            player.ownedTokis = loadPlayerTokis(playerId: player.id) ?? []
            
            // [FIXED] Load Equipment
            player.ownedEquipments = loadPlayerEquipment(playerId: player.id) ?? EquipmentComponent()
            
            players.append(player)
        }
        
        return players
    }
    
    func loadPlayer(id: UUID) -> Player? {
        guard let playersCodable: [PlayerCodable] = loadFromJson(filename: playersFileName),
              let playerCodable = playersCodable.first(where: { $0.id == id }) else {
            return nil
        }
        
        var player = playerCodable.toDomainModel()
        
        // Load Tokis
        player.ownedTokis = loadPlayerTokis(playerId: player.id) ?? []
        
        // [FIXED] Load Equipment
        player.ownedEquipments = loadPlayerEquipment(playerId: player.id) ?? EquipmentComponent()
        
        return player
    }
    
    func deletePlayer(id: UUID) -> Bool {
        // Load existing players
        guard let playersCodable: [PlayerCodable] = loadFromJson(filename: playersFileName) else {
            return false
        }
        
        // Remove the matching player
        let updatedPlayers = playersCodable.filter { $0.id != id }
        if updatedPlayers.count == playersCodable.count {
            return false
        }
        
        // Save updated players
        let playersSaved = saveToJson(updatedPlayers, filename: playersFileName)
        
        // Delete that player’s Tokis
        let tokisDeleted = deletePlayerTokis(playerId: id)
        
        // [FIXED] Delete player’s equipment
        let equipmentDeleted = deletePlayerEquipment(playerId: id)
        
        return playersSaved && tokisDeleted && equipmentDeleted
    }
    
    // MARK: - Toki Methods
    
    func savePlayerTokis(_ tokis: [Toki], playerId: UUID) -> Bool {
        let tokisCodable = tokis.map { TokiCodable(from: $0, ownerId: playerId) }
        
        var allTokis: [TokiCodable] = []
        if fileExists(filename: playerTokisFileName),
           let existingTokis: [TokiCodable] = loadFromJson(filename: playerTokisFileName) {
            // Keep tokis from other players
            allTokis = existingTokis.filter { $0.ownerId != playerId }
        }
        
        // Add current player's tokis
        allTokis.append(contentsOf: tokisCodable)
        
        return saveToJson(allTokis, filename: playerTokisFileName)
    }
    
    func loadPlayerTokis(playerId: UUID) -> [Toki]? {
        guard let allTokisCodable: [TokiCodable] = loadFromJson(filename: playerTokisFileName) else {
            return []
        }
        
        let playerTokisCodable = allTokisCodable.filter { $0.ownerId == playerId }
        
        var tokis: [Toki] = []
        
        for tokiCodable in playerTokisCodable {
            let toki = tokiCodable.toDomainModel()
            
            // Rebuild skill objects from skill names
            toki.skills = tokiCodable.skillNames.compactMap { skillName in
                guard let skillData = skillTemplates[skillName] else {
                    print("Skill template not found for name: \(skillName)")
                    return nil
                }
                return skillsFactory.createSkill(from: skillData)
            }
            
            // No direct Toki-level equipment in your code. They do reference equipmentIds in Toki,
            // but the final Toki model doesn’t automatically attach them—unless you wanted to.
            // We typically rely on Player.ownedEquipments.
            
            tokis.append(toki)
        }
        
        return tokis
    }
    
    func deletePlayerTokis(playerId: UUID) -> Bool {
        guard let allTokisCodable: [TokiCodable] = loadFromJson(filename: playerTokisFileName) else {
            return true
        }
        
        let updatedTokis = allTokisCodable.filter { $0.ownerId != playerId }
        return saveToJson(updatedTokis, filename: playerTokisFileName)
    }
    
    // MARK: - [FIXED] Equipment Methods
    
    /// A simple struct matching the layout in player_equipments.json
    struct PlayerEquipmentEntry: Codable {
        let type: String  // e.g., "nonConsumable", "potion", "candy"
        let equipment: EquipmentInfo
        
        struct EquipmentInfo: Codable {
            let id: UUID
            let name: String
            let description: String
            let rarity: Int
            let equipmentType: String // "nonConsumable" or "consumable"
            let ownerId: UUID
            
            // For nonConsumable
            let isEquipped: Bool?
            let slot: String?
            let buffValue: Int?
            let buffDescription: String?
            let affectedStat: String?
            
            // For consumable
            let consumableType: String?
            let usageContext: String?
            let bonusExp: Int?
        }
    }
    
    /// Save player's equipment to JSON
    func savePlayerEquipment(_ equipmentComponent: EquipmentComponent, playerId: UUID) -> Bool {
        // 1) Load existing equipment from player_equipments.json
        var allEquipment: [PlayerEquipmentEntry] = []
        if fileExists(filename: playerEquipmentsFileName),
           let existing: [PlayerEquipmentEntry] = loadFromJson(filename: playerEquipmentsFileName) {
            // Keep equipment owned by other players
            allEquipment = existing.filter { $0.equipment.ownerId != playerId }
        }
        
        // 2) Combine inventory + equipped items
        let allPlayerEquipment = equipmentComponent.inventory
            + equipmentComponent.equipped.values.map { $0 as Equipment }

        // 3) Convert each to PlayerEquipmentEntry
        let newEntries: [PlayerEquipmentEntry] = allPlayerEquipment.map { eq in
            // We treat NonConsumable vs Consumable
            if let nc = eq as? NonConsumableEquipment {
                return PlayerEquipmentEntry(
                    type: "nonConsumable",
                    equipment: .init(
                        id: nc.id,
                        name: nc.name,
                        description: nc.description,
                        rarity: nc.rarity,
                        equipmentType: "nonConsumable",
                        ownerId: playerId,
                        
                        isEquipped: equipmentComponent.equipped[nc.slot]?.id == nc.id,
                        slot: nc.slot.rawValue,
                        buffValue: nc.buff.value,
                        buffDescription: nc.buff.description,
                        affectedStat: nc.buff.affectedStat,
                        
                        consumableType: nil,
                        usageContext: nil,
                        bonusExp: nil
                    )
                )
                
            } else if let c = eq as? ConsumableEquipment {
                // Distinguish if it’s a “potion” or “candy” (based on name or effect strategy)
                var typeString = "consumable"
                var consumableType = "potion"  // default
                var bonusExp: Int? = nil
                
                if c.name.lowercased().contains("candy") {
                    typeString = "candy"
                    consumableType = "candy"
                } else if c.name.lowercased().contains("potion") {
                    typeString = "potion"
                    consumableType = "potion"
                }
                
                // If the effectStrategy is an UpgradeCandyEffectStrategy, capture its bonusExp
                if let candyStrategy = c.effectStrategy as? UpgradeCandyEffectStrategy {
                    bonusExp = candyStrategy.bonusExp
                    typeString = "candy"
                    consumableType = "candy"
                }
                
                // usageContext as a string
                let usageCtxString: String
                switch c.usageContext {
                case .battleOnly: usageCtxString = "battleOnly"
                case .outOfBattleOnly: usageCtxString = "outOfBattleOnly"
                case .anywhere: usageCtxString = "anywhere"
                }
                
                return PlayerEquipmentEntry(
                    type: typeString,
                    equipment: .init(
                        id: c.id,
                        name: c.name,
                        description: c.description,
                        rarity: c.rarity,
                        equipmentType: "consumable",
                        ownerId: playerId,
                        
                        isEquipped: nil, // Not used for consumables
                        slot: nil,
                        buffValue: nil,
                        buffDescription: nil,
                        affectedStat: nil,
                        
                        consumableType: consumableType,
                        usageContext: usageCtxString,
                        bonusExp: bonusExp
                    )
                )
            }
            
            // Fallback, though in practice we only have these two types
            return PlayerEquipmentEntry(
                type: "nonConsumable",
                equipment: .init(
                    id: eq.id,
                    name: eq.name,
                    description: eq.description,
                    rarity: eq.rarity,
                    equipmentType: "nonConsumable",
                    ownerId: playerId,
                    
                    isEquipped: false,
                    slot: "weapon",
                    buffValue: 0,
                    buffDescription: "Unknown",
                    affectedStat: "attack",
                    
                    consumableType: nil,
                    usageContext: nil,
                    bonusExp: nil
                )
            )
        }
        
        // 4) Append new equipment and save
        allEquipment.append(contentsOf: newEntries)
        return saveToJson(allEquipment, filename: playerEquipmentsFileName)
    }
    
    /// Load player's equipment from JSON
    func loadPlayerEquipment(playerId: UUID) -> EquipmentComponent? {
        guard let allEquipEntries: [PlayerEquipmentEntry] = loadFromJson(filename: playerEquipmentsFileName) else {
            return EquipmentComponent()
        }
        
        let playerEntries = allEquipEntries.filter { $0.equipment.ownerId == playerId }
        
        var inventory: [Equipment] = []
        var equipped: [EquipmentSlot: NonConsumableEquipment] = [:]
        
        // 2) Convert each entry to the actual Equipment object
        for entry in playerEntries {
            let eqInfo = entry.equipment
            
            if entry.type == "nonConsumable" {
                // Build NonConsumableEquipment
                let buff = EquipmentBuff(
                    value: eqInfo.buffValue ?? 0,
                    description: eqInfo.buffDescription ?? "",
                    affectedStat: eqInfo.affectedStat ?? "attack"
                )
                let slotEnum = EquipmentSlot(rawValue: eqInfo.slot ?? "weapon") ?? .weapon
                
                let nc = NonConsumableEquipment(
                    name: eqInfo.name,
                    description: eqInfo.description,
                    rarity: eqInfo.rarity,
                    buff: buff,
                    slot: slotEnum
                )
                
                // We want the same UUID
                // Because NonConsumableEquipment’s `id` is let id = UUID() in the struct,
                // you can’t set it from outside.
                // (One approach is to keep an internal dictionary if you must track exact IDs.)
                // If you truly need to preserve the original UUID,
                // you’d have to update NonConsumableEquipment to accept an ID in init.
                // But the user said “do not change the equipment system,” so we skip that.
                //
                // If isEquipped = true, put it in equipped. Otherwise, inventory.
                if eqInfo.isEquipped == true {
                    equipped[slotEnum] = nc
                } else {
                    inventory.append(nc)
                }
                
            } else {
                // type is “potion” or “candy” => ConsumableEquipment
                let usage: ConsumableUsageContext
                switch eqInfo.usageContext?.lowercased() {
                case "battleonly": usage = .battleOnly
                case "outofbattleonly": usage = .outOfBattleOnly
                default: usage = .anywhere
                }
                
                // Provide a default effect strategy
                // For candy, read bonusExp
                var strategy: ConsumableEffectStrategy = PotionEffectStrategy(effectCalculators:
                                                                                [HealCalculator(healPower: 100)])
                if eqInfo.consumableType == "candy" {
                    let bonus = eqInfo.bonusExp ?? 100
                    strategy = UpgradeCandyEffectStrategy(bonusExp: bonus)
                }
                
                let con = ConsumableEquipment(
                    name: eqInfo.name,
                    description: eqInfo.description,
                    rarity: eqInfo.rarity,
                    effectStrategy: strategy,
                    usageContext: usage
                )
                // Consumables always go to inventory (no concept of “equipped”)
                inventory.append(con)
            }
        }
        
        return EquipmentComponent(inventory: inventory, equipped: equipped)
    }
    
    /// Delete player's equipment
    func deletePlayerEquipment(playerId: UUID) -> Bool {
        guard let allEquipEntries: [PlayerEquipmentEntry] = loadFromJson(filename: playerEquipmentsFileName) else {
            return true
        }
        
        // Keep only equipment not belonging to this player
        let updated = allEquipEntries.filter { $0.equipment.ownerId != playerId }
        
        return saveToJson(updated, filename: playerEquipmentsFileName)
    }
    
    // MARK: - Initialization
    
    func initializeIfNeeded() {
        if !fileExists(filename: playersFileName) {
            let emptyPlayers: [PlayerCodable] = []
            _ = saveToJson(emptyPlayers, filename: playersFileName)
        }
        
        if !fileExists(filename: playerTokisFileName) {
            let emptyTokis: [TokiCodable] = []
            _ = saveToJson(emptyTokis, filename: playerTokisFileName)
        }
        
        if !fileExists(filename: playerEquipmentsFileName) {
            // Start empty
            let emptyEquipment: [PlayerEquipmentEntry] = []
            _ = saveToJson(emptyEquipment, filename: playerEquipmentsFileName)
        }
    }
}

