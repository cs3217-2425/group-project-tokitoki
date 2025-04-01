//
//  PlayerRepository.swift
//  TokiToki
//
//  Created by wesho on 19/3/25.
//


import CoreData
import Foundation

protocol PlayerRepository {
    func getPlayer() -> Player?
    func savePlayer(_ player: Player)
    func createDefaultPlayer(name: String) -> Player
}

class CoreDataPlayerRepository: PlayerRepository {
    private let context: NSManagedObjectContext
    private let itemRepository: ItemRepository
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.itemRepository = ItemRepository(context: context)
    }
    
    func getPlayer() -> Player? {
        let fetchRequest: NSFetchRequest<PlayerCD> = PlayerCD.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            if let playerEntity = results.first {
                return convertToPlayer(playerEntity)
            }
            return nil
        } catch {
            print("Error fetching player: \(error)")
            return nil
        }
    }
    
    func savePlayer(_ player: Player) {
        // Check if player exists first
        let fetchRequest: NSFetchRequest<PlayerCD> = PlayerCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", player.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            let playerEntity: PlayerCD
            
            if let existingPlayer = results.first {
                // Update existing player
                playerEntity = existingPlayer
            } else {
                // Create new player
                playerEntity = PlayerCD(context: context)
                playerEntity.id = player.id
            }
            
            // Update fields
            updateEntityFromPlayer(playerEntity, player)
            
            try context.save()
        } catch {
            print("Error saving player: \(error)")
        }
    }
    
    func createDefaultPlayer(name: String) -> Player {
        let player = Player(
            id: UUID(),
            name: name,
            level: 1,
            experience: 0,
            currency: 1_000,
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
    
    // MARK: - Helper Methods
    private func convertToPlayer(_ entity: PlayerCD) -> Player {
        // Load Tokis that have this player as owner
        var tokis: [Toki] = []
        if let tokiCDs = entity.tokis as? Set<TokiCD> {
            for tokiCD in tokiCDs {
                if let toki = convertTokiCDToDomain(tokiCD) {
                    tokis.append(toki)
                }
            }
        }
        
        // Load Skills that have this player as owner
        var skills: [Skill] = []
        if let skillCDs = entity.skills as? Set<SkillCD> {
            for skillCD in skillCDs {
                if let skill = convertSkillCDToDomain(skillCD) {
                    skills.append(skill)
                }
            }
        }
        
        // Load Equipment that has this player as owner
        var equipment: [Equipment] = []
        if let equipmentCDs = entity.equipments as? Set<EquipmentCD> {
            for equipmentCD in equipmentCDs {
                if let equip = convertEquipmentCDToDomain(equipmentCD) {
                    equipment.append(equip)
                }
            }
        }
        
        return Player(
            id: entity.id ?? UUID(),
            name: entity.name ?? "Player",
            level: Int(entity.level),
            experience: Int(entity.experience),
            currency: Int(entity.currency),
            statistics: Player.PlayerStatistics(
                totalBattles: Int(entity.totalBattles),
                battlesWon: Int(entity.battlesWon)
            ),
            lastLoginDate: entity.lastLoginDate ?? Date(),
            ownedTokis: tokis,
            ownedSkills: skills,
            ownedEquipments: equipment,
            pullsSinceRare: Int(entity.pullsSinceRare)
        )
    }
    
    private func updateEntityFromPlayer(_ entity: PlayerCD, _ player: Player) {
        entity.id = player.id
        entity.name = player.name
        entity.level = Int32(player.level)
        entity.experience = Int32(player.experience)
        entity.currency = Int32(player.currency)
        entity.totalBattles = Int32(player.statistics.totalBattles)
        entity.battlesWon = Int32(player.statistics.battlesWon)
        entity.lastLoginDate = player.lastLoginDate
        entity.pullsSinceRare = Int32(player.pullsSinceRare)
        
        // Update Toki relationships
        // First, get existing Tokis in Core Data
        let existingTokiCDs = entity.tokis as? Set<TokiCD> ?? []
        let existingTokiIDs = existingTokiCDs.compactMap { $0.id }
        
        // Add new Tokis and update existing ones
        for toki in player.ownedTokis {
            if !existingTokiIDs.contains(toki.id) {
                // This is a new Toki for this player
                let tokiCD = createOrGetTokiCD(from: toki)
                tokiCD.player = entity
                tokiCD.ownerId = player.id
                tokiCD.dateAcquired = toki.dateAcquired
            } else {
                // Update existing Toki
                updateTokiCD(from: toki, ownerId: player.id)
            }
        }
        
        // Remove Tokis that are no longer owned
        let currentTokiIDs = Set(player.ownedTokis.map { $0.id })
        for tokiCD in existingTokiCDs {
            if let tokiID = tokiCD.id, !currentTokiIDs.contains(tokiID) {
                entity.removeFromTokis(tokiCD)
                tokiCD.player = nil
                tokiCD.ownerId = nil
            }
        }
        
        // Similar logic for Skills and Equipment...
        // (Implement the same pattern for skills and equipment)
        
    
    }
    
    // MARK: - Conversion Methods
    
    private func convertTokiCDToDomain(_ tokiCD: TokiCD) -> Toki? {
        guard let id = tokiCD.id, let name = tokiCD.name else { return nil }
        
        // Load related skills
        var skills: [Skill] = []
        if let skillCDs = tokiCD.skills as? Set<SkillCD> {
            for skillCD in skillCDs {
                if let skill = convertSkillCDToDomain(skillCD) {
                    skills.append(skill)
                }
            }
        }
        
        // Load related equipment
        var equipment: [Equipment] = []
        if let equipmentCDs = tokiCD.equipments as? Set<EquipmentCD> {
            for equipmentCD in equipmentCDs {
                if let equip = convertEquipmentCDToDomain(equipmentCD) {
                    equipment.append(equip)
                }
            }
        }
        
        let baseStats = TokiBaseStats(
            hp: Int(tokiCD.baseHealth),
            attack: Int(tokiCD.baseAttack),
            defense: Int(tokiCD.baseDefense),
            speed: Int(tokiCD.baseSpeed),
            heal: Int(tokiCD.baseHeal),
            exp: Int(tokiCD.baseExp)
        )
        
        let rarity = convertIntToItemRarity(Int(tokiCD.rarity))
        let elementType = convertStringToElementType(tokiCD.elementType ?? "neutral")
        
        return Toki(
            id: id,
            name: name,
            rarity: rarity,
            baseStats: baseStats,
            skills: skills,
            equipments: equipment,
            elementType: elementType,
            level: Int(tokiCD.level),
            ownerId: tokiCD.ownerId,
            dateAcquired: tokiCD.dateAcquired
        )
    }
    
    private func convertSkillCDToDomain(_ skillCD: SkillCD) -> Skill? {
        guard let id = skillCD.id, let name = skillCD.name else { return nil }
        
        let rarity = convertIntToItemRarity(Int(skillCD.rarity))
        let skillType = convertStringToSkillType(skillCD.skillType ?? "attack")
        let targetType = convertStringToTargetType(skillCD.targetType ?? "singleEnemy")
        let elementType = convertStringToElementType(skillCD.elementType ?? "neutral")
        
        // Get appropriate calculator
        let effectCalculatorFactory = EffectCalculatorFactory()
        let calculator = effectCalculatorFactory.getCalculator(for: skillType)
        
        // Convert status effect
        var statusEffect: StatusEffectType? = nil
        if let statusEffectStr = skillCD.statusEffect {
            statusEffect = convertStringToStatusEffect(statusEffectStr)
        }
        
        return BaseSkill(
            id: id,
            name: name,
            description: skillCD.skillDescription ?? "",
            type: skillType,
            targetType: targetType,
            elementType: elementType,
            basePower: Int(skillCD.basePower),
            cooldown: Int(skillCD.cooldown),
            statusEffectChance: skillCD.statusEffectChance,
            statusEffect: statusEffect,
            statusEffectDuration: Int(skillCD.statusEffectDuration),
            effectCalculator: calculator,
            rarity: rarity,
            ownerId: skillCD.ownerId,
            dateAcquired: skillCD.dateAcquired
        )
    }
    
    private func convertEquipmentCDToDomain(_ equipmentCD: EquipmentCD) -> Equipment? {
        guard let id = equipmentCD.id, let name = equipmentCD.name else { return nil }
        
        let rarity = convertIntToItemRarity(Int(equipmentCD.rarity))
        let elementType = convertStringToElementType(equipmentCD.elementType ?? "neutral")
        
        // Create components
        var components: [EquipmentComponent] = []
//        if let componentsData = equipmentCD.components as? [[String: Any]] {
//            for componentData in componentsData {
//                if let type = componentData["type"] as? String,
//                   type == "statBoost",
//                   let statTypeStr = componentData["statType"] as? String,
//                   let value = componentData["value"] as? Int {
//                    let statType = convertStringToStatType(statTypeStr)
//                    components.append(StatBoostComponent(statType: statType, value: value))
//                }
//            }
//        }
        
        return Equipment(
            id: id,
            name: name,
            description: equipmentCD.equipmentDescription ?? "",
            elementType: elementType,
            components: components,
            rarity: rarity,
            ownerId: equipmentCD.ownerId,
            dateAcquired: equipmentCD.dateAcquired
        )
    }
    
    private func createOrGetTokiCD(from toki: Toki) -> TokiCD {
        // Check if this Toki already exists in Core Data
        let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", toki.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingToki = results.first {
                return existingToki
            }
        } catch {
            print("Error fetching Toki: \(error)")
        }
        
        // Create new Toki CD
        let tokiCD = TokiCD(context: context)
        tokiCD.id = toki.id
        tokiCD.name = toki.name
        tokiCD.rarity = Int16(convertItemRarityToInt(toki.rarity))
        tokiCD.baseHealth = Int16(toki.baseStats.hp)
        tokiCD.baseAttack = Int16(toki.baseStats.attack)
        tokiCD.baseDefense = Int16(toki.baseStats.defense)
        tokiCD.baseSpeed = Int16(toki.baseStats.speed)
        tokiCD.baseHeal = Int16(toki.baseStats.heal)
        tokiCD.baseExp = Int16(toki.baseStats.exp)
        tokiCD.elementType = toki.elementType.rawValue
        tokiCD.level = Int16(toki.level)
        tokiCD.ownerId = toki.ownerId
        tokiCD.dateAcquired = toki.dateAcquired
        
        return tokiCD
    }
    
    private func updateTokiCD(from toki: Toki, ownerId: UUID) {
        let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", toki.id as CVarArg)
        
        do {
            if let tokiCD = try context.fetch(fetchRequest).first {
                tokiCD.name = toki.name
                tokiCD.level = Int16(toki.level)
                tokiCD.ownerId = ownerId
                tokiCD.dateAcquired = toki.dateAcquired
                // Update other properties as needed
            }
        } catch {
            print("Error updating Toki: \(error)")
        }
    }
    
    // MARK: - Helper Conversion Methods
    
    private func convertIntToItemRarity(_ value: Int) -> ItemRarity {
        switch value {
        case 0: return .common
        case 1: return .rare
        case 2: return .legendary
        default: return .common
        }
    }
    
    private func convertItemRarityToInt(_ rarity: ItemRarity) -> Int {
        switch rarity {
        case .common: return 0
        case .rare: return 1
        case .legendary: return 2
        }
    }
    
    private func convertStringToElementType(_ str: String) -> ElementType {
        switch str.lowercased() {
        case "fire": return .fire
        case "water": return .water
        case "earth": return .earth
        case "air": return .air
        default: return .neutral
        }
    }
    
    private func convertStringToSkillType(_ str: String) -> SkillType {
        switch str.lowercased() {
        case "attack": return .attack
        case "heal": return .heal
        case "defend": return .defend
        case "buff": return .buff
        case "debuff": return .debuff
        default: return .attack
        }
    }
    
    private func convertStringToTargetType(_ str: String) -> TargetType {
        switch str.lowercased() {
        case "singleenemy": return .singleEnemy
        case "all": return .all
        case "ownself": return .ownself
        case "allallies": return .allAllies
        case "allenemies": return .allEnemies
        case "singleally": return .singleAlly
        default: return .singleEnemy
        }
    }
    
    private func convertStringToStatusEffect(_ str: String) -> StatusEffectType? {
        switch str.lowercased() {
        case "stun": return .stun
        case "poison": return .poison
        case "burn": return .burn
        case "frozen": return .frozen
        case "paralysis": return .paralysis
        case "attackbuff": return .attackBuff
        case "defensebuff": return .defenseBuff
        case "speedbuff": return .speedBuff
        case "attackdebuff": return .attackDebuff
        case "defensedebuff": return .defenseDebuff
        case "speeddebuff": return .speedDebuff
        default: return nil
        }
    }
    
//    private func convertStringToStatType(_ str: String) -> StatType {
//        switch str.lowercased() {
//        case "health": return .health
//        case "attack": return .attack
//        case "defense": return .defense
//        case "speed": return .speed
//        default: return .health
//        }
//    }
}
