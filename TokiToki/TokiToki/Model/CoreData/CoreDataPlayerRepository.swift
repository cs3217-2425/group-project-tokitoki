//
//  CoreDataPlayerRepository.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 5/4/25.
//



import CoreData
import Foundation

protocol PlayerRepository {
    func getPlayer() -> Player?
    func savePlayer(_ player: Player)
    func createDefaultPlayer(name: String) -> Player
    func deletePlayerData() -> Bool
}

class CoreDataPlayerRepository: PlayerRepository {
    private let context: NSManagedObjectContext
    private let tokiRepository: CoreDataTokiRepository
    private let skillRepository: CoreDataSkillRepository
    private let equipmentRepository: CoreDataEquipmentRepository
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.tokiRepository = CoreDataTokiRepository(context: context)
        self.skillRepository = CoreDataSkillRepository(context: context)
        self.equipmentRepository = CoreDataEquipmentRepository(context: context)
    }
    
    // MARK: - Player Operations
    
    /// Get the player from CoreData. Returns the first player found.
    func getPlayer() -> Player? {
        let playerCDs = DataManager.shared.fetch(PlayerCD.self, context: context)
        if let playerEntity = playerCDs.first {
            return convertToPlayer(playerEntity)
        }
        return nil
    }
    
    /// Save a player object to CoreData
    func savePlayer(_ player: Player) {
        // Check if player exists first
        let predicate = NSPredicate(format: "id == %@", player.id as CVarArg)
        let playerEntity: PlayerCD
        
        if let existingPlayer = DataManager.shared.fetchOne(PlayerCD.self, predicate: predicate, context: context) {
            // Update existing player
            playerEntity = existingPlayer
        } else {
            // Create new player
            playerEntity = PlayerCD(context: context)
            playerEntity.id = player.id
        }
        
        // Update fields
        updateEntityFromPlayer(playerEntity, player)
        
        // Save context
        DataManager.shared.saveContext(context)
    }
    
    /// Create a default player object
    func createDefaultPlayer(name: String) -> Player {
        let player = Player(
            id: UUID(),
            name: name,
            level: 1,
            experience: 0,
            currency: 1000,
            statistics: Player.PlayerStatistics(totalBattles: 0, battlesWon: 0),
            lastLoginDate: Date(),
            ownedTokis: [],
            ownedSkills: [],
            ownedEquipments: [],
            pullsSinceRare: 0
        )
        savePlayer(player)
        return player
    }
    
    /// Delete all player data
    func deletePlayerData() -> Bool {
        let playerCDs = DataManager.shared.fetch(PlayerCD.self, context: context)
        
        for player in playerCDs {
            context.delete(player)
        }
        
        DataManager.shared.saveContext(context)
        return true
    }
    
    // MARK: - Conversion Methods: Core Data -> Domain Model
    
    private func convertToPlayer(_ entity: PlayerCD) -> Player {
        // Convert player statistics
        let stats = Player.PlayerStatistics(
            totalBattles: Int(entity.totalBattles),
            battlesWon: Int(entity.battlesWon)
        )
        
        // Use specialized repositories to load related entities
        
        // Load Tokis
        let tokiCDs = entity.tokis as? Set<TokiCD> ?? []
        let tokis = tokiCDs.map { tokiRepository.loadToki(from: $0) }
        
        // Load Skills
        let skillCDs = entity.skills as? Set<SkillCD> ?? []
        let skills = skillCDs.map { skillRepository.loadSkill(from: $0) }
        
        // Load Equipment
        let equipmentCDs = entity.equipments as? Set<EquipmentCD> ?? []
        let equipment = equipmentCDs.map { equipmentRepository.loadEquipment(from: $0) }
        
        // Create and return the player
        return Player(
            id: entity.id ?? UUID(),
            name: entity.name ?? "Player",
            level: Int(entity.level),
            experience: Int(entity.experience),
            currency: Int(entity.currency),
            statistics: stats,
            lastLoginDate: entity.lastLoginDate ?? Date(),
            ownedTokis: tokis,
            ownedSkills: skills,
            ownedEquipments: equipment,
            pullsSinceRare: Int(entity.pullsSinceRare)
        )
    }
    
    // MARK: - Conversion Methods: Domain Model -> Core Data
    
    private func updateEntityFromPlayer(_ entity: PlayerCD, _ player: Player) {
        // Update basic player properties
        entity.id = player.id
        entity.name = player.name
        entity.level = Int32(player.level)
        entity.experience = Int32(player.experience)
        entity.currency = Int32(player.currency)
        entity.totalBattles = Int32(player.statistics.totalBattles)
        entity.battlesWon = Int32(player.statistics.battlesWon)
        entity.lastLoginDate = player.lastLoginDate
        entity.pullsSinceRare = Int32(player.pullsSinceRare)
        
        // Clear existing relationships to avoid duplicates
        if let existingTokis = entity.tokis as? Set<TokiCD> {
            for toki in existingTokis {
                entity.removeFromTokis(toki)
                context.delete(toki)
            }
        }
        
        if let existingSkills = entity.skills as? Set<SkillCD> {
            for skill in existingSkills {
                entity.removeFromSkills(skill)
                context.delete(skill)
            }
        }
        
        if let existingEquipment = entity.equipments as? Set<EquipmentCD> {
            for equipment in existingEquipment {
                entity.removeFromEquipments(equipment)
                context.delete(equipment)
            }
        }
        
        // Use specialized repositories to save related entities
        
        // Save Tokis
        for toki in player.ownedTokis {
            let tokiEntity = tokiRepository.saveToki(toki, ownerId: player.id)
            entity.addToTokis(tokiEntity)
        }
        
        // Save Skills
        for skill in player.ownedSkills {
            let skillEntity = skillRepository.saveSkill(skill, ownerId: player.id)
            entity.addToSkills(skillEntity)
        }
        
        // Save Equipment
        for equipment in player.ownedEquipments {
            let equipmentEntity = equipmentRepository.saveEquipment(equipment, ownerId: player.id)
            entity.addToEquipments(equipmentEntity)
        }
    }
    
    // MARK: - Additional Operations
    
    /// Find player by ID
    func findPlayerById(_ playerId: UUID) -> Player? {
        let predicate = NSPredicate(format: "id == %@", playerId as CVarArg)
        if let playerCD = DataManager.shared.fetchOne(PlayerCD.self, predicate: predicate, context: context) {
            return convertToPlayer(playerCD)
        }
        return nil
    }
    
    /// Add a Toki to a player
    func addTokiToPlayer(_ toki: Toki, playerId: UUID) -> Bool {
        let predicate = NSPredicate(format: "id == %@", playerId as CVarArg)
        if let playerCD = DataManager.shared.fetchOne(PlayerCD.self, predicate: predicate, context: context) {
            let tokiCD = tokiRepository.saveToki(toki, ownerId: playerId)
            playerCD.addToTokis(tokiCD)
            DataManager.shared.saveContext(context)
            return true
        }
        return false
    }
    
    /// Add a Skill to a player
    func addSkillToPlayer(_ skill: Skill, playerId: UUID) -> Bool {
        let predicate = NSPredicate(format: "id == %@", playerId as CVarArg)
        if let playerCD = DataManager.shared.fetchOne(PlayerCD.self, predicate: predicate, context: context) {
            let skillCD = skillRepository.saveSkill(skill, ownerId: playerId)
            playerCD.addToSkills(skillCD)
            DataManager.shared.saveContext(context)
            return true
        }
        return false
    }
    
    /// Add Equipment to a player
    func addEquipmentToPlayer(_ equipment: Equipment, playerId: UUID) -> Bool {
        let predicate = NSPredicate(format: "id == %@", playerId as CVarArg)
        if let playerCD = DataManager.shared.fetchOne(PlayerCD.self, predicate: predicate, context: context) {
            let equipmentCD = equipmentRepository.saveEquipment(equipment, ownerId: playerId)
            playerCD.addToEquipments(equipmentCD)
            DataManager.shared.saveContext(context)
            return true
        }
        return false
    }
}

