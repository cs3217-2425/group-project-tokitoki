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
    
    /// Get URL for document directory
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Get URL for a specific file
    private func getFileURL(filename: String) -> URL {
        getDocumentsDirectory().appendingPathComponent(filename).appendingPathExtension("json")
    }
    
    /// Check if a file exists
    private func fileExists(filename: String) -> Bool {
        FileManager.default.fileExists(atPath: getFileURL(filename: filename).path)
    }
    
    // MARK: - Generic Read/Write Methods
    
    /// Save Codable object to JSON file
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
    
    /// Load Codable object from JSON file
    private func loadFromJson<T: Decodable>(filename: String) -> T? {
        var fileURL = getFileURL(filename: filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
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
    
    /// Delete a JSON file
    func deleteJson(filename: String) -> Bool {
        let fileURL = getFileURL(filename: filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return true // File doesn't exist, so deletion is "successful"
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
    
    /// Save players to JSON
    func savePlayers(_ players: [Player]) -> Bool {
        let playersCodable = players.map { PlayerCodable(from: $0) }
        return saveToJson(playersCodable, filename: playersFileName)
    }
    
    /// Save a single player to JSON
    func savePlayer(_ player: Player) -> Bool {
        // First check if players file exists and load existing players
        var players: [PlayerCodable] = []
        
        if fileExists(filename: playersFileName), let existingPlayers: [PlayerCodable] = loadFromJson(filename: playersFileName) {
            players = existingPlayers
        }
        
        // Convert the player to Codable
        let playerCodable = PlayerCodable(from: player)
        
        // Update or add the player
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = playerCodable
        } else {
            players.append(playerCodable)
        }
        
        
        // Save players
        let playersSaved = saveToJson(players, filename: playersFileName)
        
        // Save player's tokis
        let tokisSaved = savePlayerTokis(player.ownedTokis, playerId: player.id)
        
        // Save player's equipment
//        let equipmentSaved = savePlayerEquipment(player.ownedEquipments, playerId: player.id)
        
        return playersSaved && tokisSaved /*&& equipmentSaved*/
    }
    
    /// Load all players from JSON
    func loadPlayers() -> [Player]? {
        guard let playersCodable: [PlayerCodable] = loadFromJson(filename: playersFileName) else {
            return nil
        }
        
        var players: [Player] = []
        
        for playerCodable in playersCodable {
            var player = playerCodable.toDomainModel()
            
            // Load player's tokis
            player.ownedTokis = loadPlayerTokis(playerId: player.id) ?? []
            
            // Load player's equipment
            //            player.ownedEquipments = loadPlayerEquipment(playerId: player.id) ?? EquipmentComponent()
            
            players.append(player)
        }
        
        return players
    }
    
    /// Load a single player by ID
    func loadPlayer(id: UUID) -> Player? {
        guard let playersCodable: [PlayerCodable] = loadFromJson(filename: playersFileName),
              let playerCodable = playersCodable.first(where: { $0.id == id }) else {
            return nil
        }
        
        // Create base player from Codable
        var player = playerCodable.toDomainModel()
        
        // Load player's tokis
        player.ownedTokis = loadPlayerTokis(playerId: player.id) ?? []
        
        // Load player's equipment
        //        player.ownedEquipments = loadPlayerEquipment(playerId: player.id) ?? EquipmentComponent()
        
        return player
    }
    
    /// Delete a player by ID
    func deletePlayer(id: UUID) -> Bool {
        // Load existing players
        guard let playersCodable: [PlayerCodable] = loadFromJson(filename: playersFileName) else {
            return false
        }
        
        // Remove the player
        let updatedPlayers = playersCodable.filter { $0.id != id }
        
        // If nothing was removed, return false
        if updatedPlayers.count == playersCodable.count {
            return false
        }
        
        // Save updated players
        let playersSaved = saveToJson(updatedPlayers, filename: playersFileName)
        
        // Delete player's tokis
        let tokisDeleted = deletePlayerTokis(playerId: id)
        
        // Delete player's equipment
        //        let equipmentDeleted = deletePlayerEquipment(playerId: id)
        
        return playersSaved && tokisDeleted /*&& equipmentDeleted*/
    }
    
    // MARK: - Toki Methods
    
    /// Save player's tokis to JSON
    func savePlayerTokis(_ tokis: [Toki], playerId: UUID) -> Bool {
        // Create Codable tokis
        let tokisCodable = tokis.map { TokiCodable(from: $0, ownerId: playerId) }
        
        // First, load existing tokis for all players
        var allTokis: [TokiCodable] = []
        
        if fileExists(filename: playerTokisFileName), let existingTokis: [TokiCodable] = loadFromJson(filename: playerTokisFileName) {
            // Keep tokis from other players
            allTokis = existingTokis.filter { $0.ownerId != playerId }
        }
        
        // Add the current player's tokis
        allTokis.append(contentsOf: tokisCodable)
        
        // Save all tokis
        return saveToJson(allTokis, filename: playerTokisFileName)
    }
    
    /// Load player's tokis from JSON
    func loadPlayerTokis(playerId: UUID) -> [Toki]? {
        // Load all tokis
        guard let allTokisCodable: [TokiCodable] = loadFromJson(filename: playerTokisFileName) else {
            return []
        }
        
        // Filter tokis for this player
        let playerTokisCodable = allTokisCodable.filter { $0.ownerId == playerId }
        
        
        // Load player's equipment
        //        let playerEquipmentComponent = loadPlayerEquipment(playerId: playerId) ?? EquipmentComponent()
        //        let allPlayerEquipment = playerEquipmentComponent.inventory + Array(playerEquipmentComponent.equipped.values)
        
        // Convert Codable tokis to domain models
        var tokis: [Toki] = []
        
        for tokiCodable in playerTokisCodable {
            let toki = tokiCodable.toDomainModel()
            
            // Create skills using skill factory based on names
            toki.skills = tokiCodable.skillNames.compactMap(
                { skillName in
                    guard let skillData = skillTemplates[skillName] else {
                        print("Skill template not found for name: \(skillName)")
                        return nil
                    }
                    
                    // Create the skill using the factory
                    return skillsFactory.createSkill(from: skillData)
                }
            )
            
            // Add equipment based on equipment IDs
//            toki.equipments = tokiCodable.equipmentIds.compactMap { equipmentId in
//                allPlayerEquipment.first { $0.id == equipmentId }
//            }
            
            tokis.append(toki)
        }
        
        return tokis
    }
    
    /// Delete player's tokis
    func deletePlayerTokis(playerId: UUID) -> Bool {
        // Load all tokis
        guard let allTokisCodable: [TokiCodable] = loadFromJson(filename: playerTokisFileName) else {
            return true
        }
        
        // Keep tokis from other players
        let updatedTokis = allTokisCodable.filter { $0.ownerId != playerId }
        
        // Save updated tokis
        return saveToJson(updatedTokis, filename: playerTokisFileName)
    }
    
    // MARK: - Equipment Methods
    
    /// Save player's equipment to JSON
//    func savePlayerEquipment(_ equipmentComponent: EquipmentComponent, playerId: UUID) -> Bool {
        // Create equipment container with all equipment (both inventory and equipped)
        //        let equipmentContainer = EquipmentContainer(
        //            from: equipmentComponent.inventory,
        //            ownerId: playerId,
        //            equipped: equipmentComponent.equipped
        //        )
        
        //        // Load existing equipment for all players
        //        var allEquipment: [AnyEquipment] = []
        //
        //        if fileExists(filename: playerEquipmentsFileName),
        // let existingEquipment: EquipmentContainer = loadFromJson(filename: playerEquipmentsFileName) {
        //            // Keep equipment from other players
        //            allEquipment = existingEquipment.equipments.filter {
        //                switch $0.equipment {
        //                case .nonConsumable(let eq): return eq.ownerId != playerId
        //                case .potion(let eq): return eq.ownerId != playerId
        //                case .candy(let eq): return eq.ownerId != playerId
        //                }
        //            }
        //        }
        
        // Add current player's equipment
        //        allEquipment.append(contentsOf: equipmentContainer.equipments)
        
        // Save all equipment
        //        return saveToJson(EquipmentContainer(equipments: allEquipment), filename: playerEquipmentsFileName)
//    }
    
    /// Load player's equipment from JSON
    //    func loadPlayerEquipment(playerId: UUID) -> EquipmentComponent? {
    //        // Load all equipment
    ////        guard let allEquipment: EquipmentContainer = loadFromJson(filename: playerEquipmentsFileName) else {
    //            return EquipmentComponent()
    //        }
    //
    //        // Filter equipment for this player
    //        let playerEquipment = allEquipment.equipments.filter {
    //            switch $0.equipment {
    //            case .nonConsumable(let eq): return eq.ownerId == playerId
    //            case .potion(let eq): return eq.ownerId == playerId
    //            case .candy(let eq): return eq.ownerId == playerId
    //            }
    //        }
    //
    //        // Create equipment component
    //        var inventory: [Equipment] = []
    //        var equipped: [EquipmentSlot: NonConsumableEquipment] = [:]
    //
    //        for anyEquipment in playerEquipment {
    //            switch anyEquipment.equipment {
    //            case .nonConsumable(let eq):
    //                let equipment = eq.toDomainModel() as! NonConsumableEquipment
    //                if eq.isEquipped {
    //                    equipped[EquipmentSlot(rawValue: eq.slot) ?? .weapon] = equipment
    //                } else {
    //                    inventory.append(equipment)
    //                }
    //            case .potion(let eq):
    //                inventory.append(eq.toDomainModel())
    //            case .candy(let eq):
    //                inventory.append(eq.toDomainModel())
    //            }
    //        }
    //
    //        return EquipmentComponent(inventory: inventory, equipped: equipped)
    //    }
    //
    //    /// Delete player's equipment
    //    func deletePlayerEquipment(playerId: UUID) -> Bool {
    //        // Load all equipment
    ////        guard let allEquipment: EquipmentContainer = loadFromJson(filename: playerEquipmentsFileName) else {
    ////            return true
    ////        }
    //
    //        // Keep equipment from other players
    ////        let updatedEquipment = allEquipment.equipments.filter {
    ////            switch $0.equipment {
    ////            case .nonConsumable(let eq): return eq.ownerId != playerId
    ////            case .potion(let eq): return eq.ownerId != playerId
    ////            case .candy(let eq): return eq.ownerId != playerId
    ////            }
    ////        }
    //
    //        // Save updated equipment
    ////        return saveToJson(EquipmentContainer(equipments: updatedEquipment), filename: playerEquipmentsFileName)
    //    }
    //
    //
    //
    //    // MARK: - Initialization
    //
    //    /// Initialize the persistence system with default data if needed
    //    func initializeIfNeeded() {
    //        // Check if players file exists
    //        if !fileExists(filename: playersFileName) {
    //            // Create an empty players array
    //            let emptyPlayers: [PlayerCodable] = []
    //            _ = saveToJson(emptyPlayers, filename: playersFileName)
    //        }
    //
    //        // Check if player tokis file exists
    //        if !fileExists(filename: playerTokisFileName) {
    //            // Create an empty tokis array
    //            let emptyTokis: [TokiCodable] = []
    //            _ = saveToJson(emptyTokis, filename: playerTokisFileName)
    //        }
    //
    //        // Check if player equipments file exists
    //        if !fileExists(filename: playerEquipmentsFileName) {
    //            // Create an empty equipment container
    ////            let emptyEquipment = EquipmentContainer(equipments: [])
    //            _ = saveToJson(emptyEquipment, filename: playerEquipmentsFileName)
    //        }
    //
    //
    //        // Note: We don't initialize skills.json as it's a template file that should be included in the app bundle
    //    }
    //}
}
