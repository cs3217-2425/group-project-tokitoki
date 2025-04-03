//import CoreData
//import Foundation
//
//protocol PlayerRepository {
//    func getPlayer() -> Player?
//    func savePlayer(_ player: Player)
//    func createDefaultPlayer(name: String) -> Player
//}
//
//class CoreDataPlayerRepository: PlayerRepository {
//    private let context: NSManagedObjectContext
//    
//    init(context: NSManagedObjectContext) {
//        self.context = context
//    }
//    
//    // MARK: - Get / Save Player
//    
//    func getPlayer() -> Player? {
//        let fetchRequest: NSFetchRequest<PlayerCD> = PlayerCD.fetchRequest()
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let playerEntity = results.first {
//                return convertToPlayer(playerEntity)
//            }
//            return nil
//        } catch {
//            print("Error fetching player: \(error)")
//            return nil
//        }
//    }
//    
//    func savePlayer(_ player: Player) {
//        // Check if PlayerCD already exists
//        let fetchRequest: NSFetchRequest<PlayerCD> = PlayerCD.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", player.id as CVarArg)
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            let playerEntity: PlayerCD
//            
//            if let existingPlayer = results.first {
//                // Update existing
//                playerEntity = existingPlayer
//            } else {
//                // Create new
//                playerEntity = PlayerCD(context: context)
//                playerEntity.id = player.id
//            }
//            
//            // Update PlayerCD properties from Player
//            updateEntityFromPlayer(playerEntity, player)
//            
//            try context.save()
//        } catch {
//            print("Error saving player: \(error)")
//        }
//    }
//    
//    func createDefaultPlayer(name: String) -> Player {
//        let player = Player(
//            id: UUID(),
//            name: name,
//            level: 1,
//            experience: 0,
//            currency: 1000,
//            statistics: Player.PlayerStatistics(totalBattles: 0, battlesWon: 0),
//            lastLoginDate: Date(),
//            ownedTokis: [],
//            ownedSkills: [],
//            ownedEquipments: [],
//            pullsSinceRare: 0
//        )
//        savePlayer(player)
//        return player
//    }
//    
//    // MARK: - Conversion from PlayerCD to Domain
//    
//    private func convertToPlayer(_ entity: PlayerCD) -> Player {
//        // Convert relationships
//        let tokis = convertTokis(for: entity)
//        let skills = convertSkills(for: entity)
//        let equipments = convertEquipments(for: entity)
//        
//        return Player(
//            id: entity.id ?? UUID(),
//            name: entity.name ?? "Player",
//            level: Int(entity.level),
//            experience: Int(entity.experience),
//            currency: Int(entity.currency),
//            statistics: Player.PlayerStatistics(
//                totalBattles: Int(entity.totalBattles),
//                battlesWon: Int(entity.battlesWon)
//            ),
//            lastLoginDate: entity.lastLoginDate ?? Date(),
//            ownedTokis: tokis,
//            ownedSkills: skills,
//            ownedEquipments: equipments,
//            pullsSinceRare: Int(entity.pullsSinceRare)
//        )
//    }
//    
//    /// Convert the `PlayerCD.tokis` relationship to an array of domain `Toki`.
//    private func convertTokis(for playerEntity: PlayerCD) -> [Toki] {
//        guard let tokiCDs = playerEntity.tokis as? Set<TokiCD> else { return [] }
//        return tokiCDs.compactMap { convertTokiCDToDomain($0) }
//    }
//    
//    /// Convert the `PlayerCD.skills` relationship to an array of domain `Skill`.
//    private func convertSkills(for playerEntity: PlayerCD) -> [Skill] {
//        guard let skillCDs = playerEntity.skills as? Set<SkillCD> else { return [] }
//        return skillCDs.compactMap { convertSkillCDToDomain($0) }
//    }
//    
//    /// Convert the `PlayerCD.equipments` relationship to an array of domain `Equipment`.
//    private func convertEquipments(for playerEntity: PlayerCD) -> [Equipment] {
//        guard let equipCDs = playerEntity.equipments as? Set<EquipmentCD> else { return [] }
//        return equipCDs.compactMap { convertEquipmentCDToDomain($0) }
//    }
//    
// 
//    
//    
//    // MARK: - TokiCD
//
//    private func createOrGetTokiCD(from toki: Toki) -> TokiCD {
//        let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", toki.id as CVarArg)
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let existing = results.first {
//                return existing
//            }
//        } catch {
//            print("Error fetching TokiCD: \(error)")
//        }
//        
//        // If not found, create a new TokiCD
//        let newTokiCD = TokiCD(context: context)
//        newTokiCD.id = toki.id
//        
//        // Initial fill from Toki
//        newTokiCD.name = toki.name
//        newTokiCD.rarity = Int16(toki.rarity.value)
//        newTokiCD.level = Int16(toki.level)
//        newTokiCD.baseHealth = Int16(toki.baseStats.hp)
//        newTokiCD.baseAttack = Int16(toki.baseStats.attack)
//        newTokiCD.baseDefense = Int16(toki.baseStats.defense)
//        newTokiCD.baseSpeed = Int16(toki.baseStats.speed)
//        newTokiCD.baseHeal = Int16(toki.baseStats.heal)
//        newTokiCD.baseExp = Int16(toki.baseStats.exp)
//        newTokiCD.elementType = toki.elementType.rawValue
//        
//        return newTokiCD
//    }
//    
//    private func updateTokiCD(from toki: Toki, ownerId: UUID) {
//        let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", toki.id as CVarArg)
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let existing = results.first {
//                // Update fields
//                existing.name = toki.name
//                existing.rarity = Int16(toki.rarity.value)
//                existing.level = Int16(toki.level)
//                existing.baseHealth = Int16(toki.baseStats.hp)
//                existing.baseAttack = Int16(toki.baseStats.attack)
//                existing.baseDefense = Int16(toki.baseStats.defense)
//                existing.baseSpeed = Int16(toki.baseStats.speed)
//                existing.baseHeal = Int16(toki.baseStats.heal)
//                existing.baseExp = Int16(toki.baseStats.exp)
//                existing.elementType = toki.elementType.rawValue
//            }
//            
//            // You could also store `ownerId` if TokiCD had a field for it
//            try context.save()
//        } catch {
//            print("Error updating TokiCD: \(error)")
//        }
//    }
//    
//    /// Convert a `TokiCD` entity back to a domain `Toki`.
//    private func convertTokiCDToDomain(_ cd: TokiCD) -> Toki? {
//        // Make sure we can parse the item rarity
//        guard let itemRarity = ItemRarity(intValue: Int(cd.rarity)) else { return nil }
//        let baseStats = TokiBaseStats(
//            hp: Int(cd.baseHealth),
//            attack: Int(cd.baseAttack),
//            defense: Int(cd.baseDefense),
//            speed: Int(cd.baseSpeed),
//            heal: Int(cd.baseHeal),
//            exp: Int(cd.baseExp)
//        )
//        
//        // Convert element type if you store it as a raw string
//        let element = ElementType(rawValue: cd.elementType?.lowercased() ?? "neutral") ?? .neutral
//        
//        return Toki(
//            id: cd.id ?? UUID(),
//            name: cd.name ?? "Unknown Toki",
//            rarity: itemRarity,
//            baseStats: baseStats,
//            skills: [],        // If you store Toki's skills in TokiCD, fetch them here
//            equipments: [],    // If you store Toki's equipment in TokiCD, fetch them here
//            elementType: element,
//            level: Int(cd.level)
//        )
//    }
//
//    // MARK: - SkillCD
//
//    private func createOrGetSkillCD(from skill: Skill) -> SkillCD {
//        let fetchRequest: NSFetchRequest<SkillCD> = SkillCD.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", skill.id as CVarArg)
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let existing = results.first {
//                return existing
//            }
//        } catch {
//            print("Error fetching SkillCD: \(error)")
//        }
//        
//        // If not found, create new
//        let newSkillCD = SkillCD(context: context)
//        newSkillCD.id = skill.id
//        newSkillCD.name = skill.name
//        newSkillCD.desc = skill.description
//        newSkillCD.elementType = skill.elementType.rawValue
//        // If your model has skillType, basePower, rarity, etc., set them:
//        // newSkillCD.skillType = skill.skillType.rawValue
//        // newSkillCD.basePower = Int16(skill.basePower)
//        // ...
//        
//        return newSkillCD
//    }
//    
//    private func updateSkillCD(from skill: Skill, ownerId: UUID) {
//        let fetchRequest: NSFetchRequest<SkillCD> = SkillCD.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", skill.id as CVarArg)
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let existing = results.first {
//                // Update fields
//                existing.name = skill.name
//                existing.desc = skill.description
//                existing.elementType = skill.elementType.rawValue
//                // ...
//                // existing.skillType = skill.skillType.rawValue
//                // existing.basePower = Int16(skill.basePower)
//            }
//            try context.save()
//        } catch {
//            print("Error updating SkillCD: \(error)")
//        }
//    }
//    
//    private func convertSkillCDToDomain(_ cd: SkillCD) -> Skill? {
//        // Create an actual Skill domain object from the SkillCD
//        // If you have a "SkillFactory" or similar, call it here
//        // For illustration, we do minimal direct mapping:
//        
//        let element = ElementType(rawValue: cd.elementType?.lowercased() ?? "neutral") ?? .neutral
//        // Convert skillType if you store it, etc.
//        
//        // Suppose you have something like:
//        return BaseSkill(
//            id: cd.id ?? UUID(),
//            name: cd.name ?? "Unknown Skill",
//            description: cd.desc ?? "",
//            elementType: element,
//            basePower: 0,   // If your model has basePower
//            cooldown: 0,    // If your model has cooldown
//            targetType: .singleEnemy
//        )
//    }
//    
//    // MARK: - EquipmentCD
//
//    private func createOrGetEquipmentCD(from equipment: Equipment) -> EquipmentCD {
//        let fetchRequest: NSFetchRequest<EquipmentCD> = EquipmentCD.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", equipment.id as CVarArg)
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let existing = results.first {
//                return existing
//            }
//        } catch {
//            print("Error fetching EquipmentCD: \(error)")
//        }
//        
//        // If not found, create new
//        let newEquipCD = EquipmentCD(context: context)
//        newEquipCD.id = equipment.id
//        newEquipCD.name = equipment.name
//        newEquipCD.rarity = Int32(equipment.rarity)
//        // If you store elementType, buff, slot, etc., set them:
//        // newEquipCD.elementType = ...
//        // newEquipCD.slot = ...
//        
//        return newEquipCD
//    }
//    
//    private func updateEquipmentCD(from equipment: Equipment, ownerId: UUID) {
//        let fetchRequest: NSFetchRequest<EquipmentCD> = EquipmentCD.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", equipment.id as CVarArg)
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let existing = results.first {
//                // Update fields
//                existing.name = equipment.name
//                existing.rarity = Int32(equipment.rarity)
//                // ...
//            }
//            try context.save()
//        } catch {
//            print("Error updating EquipmentCD: \(error)")
//        }
//    }
//    
//    private func convertEquipmentCDToDomain(_ cd: EquipmentCD) -> Equipment? {
//        // Convert to your domain model. If you have a repository or factory, use that.
//        // Minimally:
//        let eqName = cd.name ?? "Unknown Equipment"
//        let eqRarity = Int(cd.rarity)
//        
//        // Example: If you store equipment as a NonConsumableEquipment or ConsumableEquipment
//        // you might do something like:
//        return Equipment(
//            id: cd.id ?? UUID(),
//            name: eqName,
//            rarity: eqRarity,
//            // fill in any buffs or effect strategies if you store them
//            description: "Some equipment"
//        )
//    }
//}
//
