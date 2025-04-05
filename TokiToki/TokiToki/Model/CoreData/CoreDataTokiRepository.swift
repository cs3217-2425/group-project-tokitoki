//
//  TokiRepository.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 5/4/25.
//


//
//  TokiRepository.swift
//  TokiToki
//

import CoreData
import Foundation

class CoreDataTokiRepository {
    private let context: NSManagedObjectContext
    private let skillRepository: CoreDataSkillRepository
    private let equipmentRepository: CoreDataEquipmentRepository
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.skillRepository = CoreDataSkillRepository(context: context)
        self.equipmentRepository = CoreDataEquipmentRepository(context: context)
    }
    
    // MARK: - Save Operations
    
    /// Save a Toki to Core Data
    func saveToki(_ toki: Toki, ownerId: UUID? = nil) -> TokiCD {
        // Create or retrieve the Toki entity
        let tokiCD = TokiCD(context: context)
        
        // Set basic properties
        tokiCD.id = toki.id
        tokiCD.name = toki.name
        tokiCD.level = Int16(toki.level)
        tokiCD.rarity = Int16(toki.rarity.value)
        tokiCD.baseHealth = Int16(toki.baseStats.hp)
        tokiCD.baseAttack = Int16(toki.baseStats.attack)
        tokiCD.baseDefense = Int16(toki.baseStats.defense)
        tokiCD.baseSpeed = Int16(toki.baseStats.speed)
        tokiCD.baseHeal = Int16(toki.baseStats.heal)
        tokiCD.baseExp = Int16(toki.baseStats.exp)
        tokiCD.elementType = toki.elementType.map { $0.rawValue }.joined(separator: ",")
        tokiCD.ownerId = ownerId
        tokiCD.dateAcquired = Date()
        
        // Clear existing relationships if any
        if let existingSkills = tokiCD.skills as? Set<SkillCD> {
            for skill in existingSkills {
                tokiCD.removeFromSkills(skill)
            }
        }
        
        if let existingEquipment = tokiCD.equipments as? Set<EquipmentCD> {
            for equipment in existingEquipment {
                tokiCD.removeFromEquipments(equipment)
            }
        }
        
        // Add skills to Toki using SkillRepository
        for skill in toki.skills {
            let skillEntity = skillRepository.saveSkill(skill, ownerId: ownerId)
            tokiCD.addToSkills(skillEntity)
        }
        
        // Add equipment to Toki
        for equipment in toki.equipments {
            let equipmentEntity = equipmentRepository.saveEquipment(equipment, ownerId: ownerId)
            tokiCD.addToEquipments(equipmentEntity)
        }
        
        // Save context
        DataManager.shared.saveContext(context)
        
        return tokiCD
    }
    
    // MARK: - Load Operations
    
    /// Load a Toki from Core Data
    func loadToki(from tokiCD: TokiCD) -> Toki {
        // Convert base stats
        let baseStats = TokiBaseStats(
            hp: Int(tokiCD.baseHealth),
            attack: Int(tokiCD.baseAttack),
            defense: Int(tokiCD.baseDefense),
            speed: Int(tokiCD.baseSpeed),
            heal: Int(tokiCD.baseHeal),
            exp: Int(tokiCD.baseExp),
            critHitChance: 15, // Default value if not stored
            critHitDamage: 150  // Default value if not stored
        )
        
        // Convert element types
        let elementTypeString = tokiCD.elementType ?? "neutral"
        let elementTypes = elementTypeString.contains(",")
            ? elementTypeString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            : [elementTypeString]
        
        // Convert strings to ElementType
        let elementType: [ElementType] = elementTypes.compactMap {
            ElementType.fromString($0) ?? .neutral
        }
        
        // Convert rarity
        let rarityInt = Int(tokiCD.rarity)
        let rarity = ItemRarity(intValue: rarityInt) ?? .common
        
        // Convert skills using SkillRepository
        let skillCDs = tokiCD.skills as? Set<SkillCD> ?? []
        let skills = skillCDs.map { skillRepository.loadSkill(from: $0) }
        
        // Convert equipment using EquipmentRepository
        let equipmentCDs = tokiCD.equipments as? Set<EquipmentCD> ?? []
        let equipment = equipmentCDs.map { equipmentRepository.loadEquipment(from: $0) }
        
        // Create and return the Toki
        return Toki(
            id: tokiCD.id ?? UUID(),
            name: tokiCD.name ?? "Unknown Toki",
            rarity: rarity,
            baseStats: baseStats,
            skills: skills,
            equipments: equipment,
            elementType: elementType,
            level: Int(tokiCD.level)
        )
    }
    
    // MARK: - Batch Operations
    
    /// Save multiple Tokis to Core Data
    func saveTokis(_ tokis: [Toki], ownerId: UUID? = nil) {
        for toki in tokis {
            _ = saveToki(toki, ownerId: ownerId)
        }
    }
    
    /// Load multiple Tokis from Core Data
    func loadTokis(from tokiCDs: [TokiCD]) -> [Toki] {
        return tokiCDs.map { loadToki(from: $0) }
    }
    
    /// Find all Tokis owned by a player
    func findTokisOwnedBy(playerId: UUID) -> [Toki] {
        let predicate = NSPredicate(format: "ownerId == %@", playerId as CVarArg)
        let tokiCDs = DataManager.shared.fetch(TokiCD.self, predicate: predicate, context: context)
        return loadTokis(from: tokiCDs)
    }
    
    /// Delete a Toki from Core Data
    func deleteToki(_ tokiId: UUID) -> Bool {
        let predicate = NSPredicate(format: "id == %@", tokiId as CVarArg)
        if let tokiCD = DataManager.shared.fetchOne(TokiCD.self, predicate: predicate, context: context) {
            DataManager.shared.delete(tokiCD, context: context)
            return true
        }
        return false
    }
}
