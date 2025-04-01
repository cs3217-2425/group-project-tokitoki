//
//  ItemRepository.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//


import Foundation
import CoreData

class ItemRepository {
    // Templates loaded from JSON
    private var tokiTemplates: [String: Toki] = [:]
    private var skillTemplates: [String: Skill] = [:]
    private var equipmentTemplates: [String: Equipment] = [:]
    
    // Player-owned instances from Core Data
    private var playerTokis: [UUID: Toki] = [:]
    private var playerSkills: [UUID: Skill] = [:]
    private var playerEquipment: [UUID: Equipment] = [:]
    
    private let context: NSManagedObjectContext
    private let effectCalculatorFactory = EffectCalculatorFactory()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Data Initialization
    
    func initializeData() {
        loadTemplatesFromJSON()
        loadPlayerItemsFromCoreData()
    }
    
    private func loadTemplatesFromJSON() {
        // Load Toki templates
        do {
            let tokisData: TokisData = try ResourceLoader.loadJSON(fromFile: "Tokis")
            
            for tokiData in tokisData.tokis {
                let baseStats = TokiBaseStats(
                    hp: tokiData.baseHealth,
                    attack: tokiData.baseAttack,
                    defense: tokiData.baseDefense,
                    speed: tokiData.baseSpeed,
                    heal: tokiData.baseHeal,
                    exp: tokiData.baseExp
                )
                
                let rarity = convertIntToRarity(tokiData.rarity)
                let elementType = convertStringToElement(tokiData.elementType)
                
                // Template tokis start with no skills or equipment
                let toki = Toki(
                    name: tokiData.name,
                    rarity: rarity,
                    baseStats: baseStats,
                    skills: [],
                    equipments: [],
                    elementType: elementType,
                    level: 1
                )
                
                tokiTemplates[tokiData.name] = toki
            }
            
            print("Loaded \(tokiTemplates.count) Toki templates from JSON")
        } catch {
            print("Error loading Toki templates: \(error)")
        }
        
        // Load Skill templates
        do {
            let skillsData: SkillsData = try ResourceLoader.loadJSON(fromFile: "Skills")
            
            for skillData in skillsData.skills {
                let rarity = convertIntToRarity(skillData.rarity)
                let skillType = convertStringToSkillType(skillData.skillType)
                let targetType = convertStringToTargetType(skillData.targetType)
                let elementType = convertStringToElement(skillData.elementType)
                
                // Get appropriate calculator based on skill type
                let calculator = effectCalculatorFactory.getCalculator(for: skillType)
                
                // Convert optional status effect
                var statusEffect: StatusEffectType? = nil
                if let statusEffectStr = skillData.statusEffect {
                    statusEffect = convertStringToStatusEffect(statusEffectStr)
                }
                
                let skill = BaseSkill(
                    id: UUID(),
                    name: skillData.name,
                    description: skillData.description,
                    type: skillType,
                    targetType: targetType,
                    elementType: elementType,
                    basePower: skillData.basePower,
                    cooldown: skillData.cooldown,
                    statusEffectChance: skillData.statusEffectChance ?? 0.0,
                    statusEffect: statusEffect,
                    statusEffectDuration: skillData.statusEffectDuration ?? 0,
                    effectCalculator: calculator,
                    rarity: rarity
                )
                
                skillTemplates[skillData.name] = skill
            }
            
            print("Loaded \(skillTemplates.count) Skill templates from JSON")
        } catch {
            print("Error loading Skill templates: \(error)")
        }
        
        // Load Equipment templates
        do {
            let equipmentsData: EquipmentsData = try ResourceLoader.loadJSON(fromFile: "Equipment")
            
            for equipmentData in equipmentsData.equipment {
                let rarity = convertIntToRarity(equipmentData.rarity)
                let elementType = convertStringToElement(equipmentData.elementType)
                
                // Create components
                var components: [EquipmentComponent] = []
//                for componentData in equipmentData.components {
//                    switch componentData.type.lowercased() {
//                    case "statboost":
//                        if let statTypeStr = componentData.statType, let value = componentData.value {
//                            let statType = convertStringToStatType(statTypeStr)
//                            components.append(StatBoostComponent(statType: statType, value: value))
//                        }
//                    default:
//                        break
//                    }
//                }
                
                let equipment = Equipment(
                    name: equipmentData.name,
                    description: equipmentData.description,
                    elementType: elementType,
                    components: components,
                    rarity: rarity
                )
                
                equipmentTemplates[equipmentData.name] = equipment
            }
            
            print("Loaded \(equipmentTemplates.count) Equipment templates from JSON")
        } catch {
            print("Error loading Equipment templates: \(error)")
        }
    }
    
    private func loadPlayerItemsFromCoreData() {
        // Load player-owned Tokis with their skills and equipment
        do {
            let fetchRequest: NSFetchRequest<TokiCD> = TokiCD.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "ownerId != nil")
            
            let results = try context.fetch(fetchRequest)
            
            for tokiCD in results {
                guard let id = tokiCD.id, let name = tokiCD.name else { continue }
                
                // Create base stats
                let baseStats = TokiBaseStats(
                    hp: Int(tokiCD.baseHealth),
                    attack: Int(tokiCD.baseAttack),
                    defense: Int(tokiCD.baseDefense),
                    speed: Int(tokiCD.baseSpeed),
                    heal: Int(tokiCD.baseHeal),
                    exp: Int(tokiCD.baseExp)
                )
                
                let rarity = convertIntToRarity(Int(tokiCD.rarity))
                let elementType = convertStringToElement(tokiCD.elementType ?? "neutral")
                
                // Load related skills
                var skills: [Skill] = []
                if let skillsCDs = tokiCD.skills as? Set<SkillCD> {
                    for skillCD in skillsCDs {
                        if let skill = loadSkillFromCD(skillCD) {
                            skills.append(skill)
                            playerSkills[skill.id] = skill
                        }
                    }
                }
                
                // Load related equipment
                var equipment: [Equipment] = []
                if let equipmentCDs = tokiCD.equipments as? Set<EquipmentCD> {
                    for equipmentCD in equipmentCDs {
                        if let equip = loadEquipmentFromCD(equipmentCD) {
                            equipment.append(equip)
                            playerEquipment[equip.id] = equip
                        }
                    }
                }
                
                // Create player Toki
                let playerToki = Toki(
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
                
                playerTokis[id] = playerToki
            }
            
            print("Loaded \(playerTokis.count) player-owned Tokis from Core Data with skills and equipment")
        } catch {
            print("Error loading player Tokis: \(error)")
        }
    }
    
    // Helper to load a skill from Core Data
    private func loadSkillFromCD(_ skillCD: SkillCD) -> Skill? {
        guard let id = skillCD.id, let name = skillCD.name else { return nil }
        
        let rarity = convertIntToRarity(Int(skillCD.rarity))
        let skillType = convertStringToSkillType(skillCD.skillType ?? "attack")
        let targetType = convertStringToTargetType(skillCD.targetType ?? "singleEnemy")
        let elementType = convertStringToElement(skillCD.elementType ?? "neutral")
        
        // Get appropriate calculator
        let calculator = effectCalculatorFactory.getCalculator(for: skillType)
        
        // Convert status effect
        var statusEffect: StatusEffectType? = nil
        if let statusEffectStr = skillCD.statusEffect {
            statusEffect = convertStringToStatusEffect(statusEffectStr)
        }
        
        // Create player Skill
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
    
    // Helper to load equipment from Core Data
    private func loadEquipmentFromCD(_ equipmentCD: EquipmentCD) -> Equipment? {
        guard let id = equipmentCD.id, let name = equipmentCD.name else { return nil }
        
        let rarity = convertIntToRarity(Int(equipmentCD.rarity))
        let elementType = convertStringToElement(equipmentCD.elementType ?? "neutral")
        
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
        
        // Create player Equipment
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
    
    // MARK: - Template Access Methods
    
    func getTokiTemplate(name: String) -> Toki? {
        return tokiTemplates[name]
    }
    
    func getSkillTemplate(name: String) -> Skill? {
        return skillTemplates[name]
    }
    
    func getEquipmentTemplate(name: String) -> Equipment? {
        return equipmentTemplates[name]
    }
    
    func getAllTokiTemplates() -> [Toki] {
        return Array(tokiTemplates.values)
    }
    
    func getAllSkillTemplates() -> [Skill] {
        return Array(skillTemplates.values)
    }
    
    func getAllEquipmentTemplates() -> [Equipment] {
        return Array(equipmentTemplates.values)
    }
    
    // New methods to get templates by name
    func getAllTokiTemplatesByName() -> [String: Toki] {
        return tokiTemplates
    }
    
    func getAllSkillTemplatesByName() -> [String: Skill] {
        return skillTemplates
    }
    
    func getAllEquipmentTemplatesByName() -> [String: Equipment] {
        return equipmentTemplates
    }
    
    // Combined method to get all items
    func getAllItems() -> [any IGachaItem] {
        var allItems: [any IGachaItem] = []
        allItems.append(contentsOf: getAllTokiTemplates())
        let skillsAsItems = getAllSkillTemplates().map { $0 as! any IGachaItem }
        allItems.append(contentsOf: skillsAsItems)
        allItems.append(contentsOf: getAllEquipmentTemplates())
        return allItems
    }
    
    // MARK: - Player Item Access Methods
    
    func getPlayerToki(id: UUID) -> Toki? {
        return playerTokis[id]
    }
    
    func getPlayerSkill(id: UUID) -> Skill? {
        return playerSkills[id]
    }
    
    func getPlayerEquipment(id: UUID) -> Equipment? {
        return playerEquipment[id]
    }
    
    func getPlayerTokisByOwner(ownerId: UUID) -> [Toki] {
        return playerTokis.values.filter { $0.ownerId == ownerId }
    }
    
    // MARK: - Create Player Items
    
    func createPlayerToki(from template: Toki, with skills: [Skill], equipment: [Equipment], ownerId: UUID) -> Toki {
        // Create a new instance from the template
        let playerToki = Toki(
            id: UUID(),
            name: template.name,
            rarity: template.rarity,
            baseStats: template.baseStats,
            skills: skills,
            equipments: equipment,
            elementType: template.elementType,
            level: 1,
            ownerId: ownerId,
            dateAcquired: Date()
        )
        
        // Create Core Data entry
        let tokiCD = TokiCD(context: context)
        tokiCD.id = playerToki.id
        tokiCD.name = playerToki.name
        tokiCD.rarity = Int16(convertRarityToInt(playerToki.rarity))
        tokiCD.baseHealth = Int16(playerToki.baseStats.hp)
        tokiCD.baseAttack = Int16(playerToki.baseStats.attack)
        tokiCD.baseDefense = Int16(playerToki.baseStats.defense)
        tokiCD.baseSpeed = Int16(playerToki.baseStats.speed)
        tokiCD.baseHeal = Int16(playerToki.baseStats.heal)
        tokiCD.baseExp = Int16(playerToki.baseStats.exp)
        tokiCD.elementType = playerToki.elementType.rawValue
        tokiCD.level = 1
        tokiCD.ownerId = ownerId
        tokiCD.dateAcquired = playerToki.dateAcquired
        
        // Create or link skills
        var skillCDs: Set<SkillCD> = []
        for skill in skills {
            let skillCD = createOrUpdateSkillCD(from: skill, ownerId: ownerId)
            skillCDs.insert(skillCD)
        }
        tokiCD.skills = skillCDs as NSSet
        
        // Create or link equipment
        var equipmentCDs: Set<EquipmentCD> = []
        for equip in equipment {
            let equipmentCD = createOrUpdateEquipmentCD(from: equip, ownerId: ownerId)
            equipmentCDs.insert(equipmentCD)
        }
        tokiCD.equipments = equipmentCDs as NSSet
        
        try? context.save()
        
        // Add to in-memory cache
        playerTokis[playerToki.id] = playerToki
        
        // Also cache the skills and equipment
        for skill in skills {
            playerSkills[skill.id] = skill
        }
        
        for equip in equipment {
            playerEquipment[equip.id] = equip
        }
        
        return playerToki
    }
    
    // Create or update a SkillCD entity
    private func createOrUpdateSkillCD(from skill: Skill, ownerId: UUID) -> SkillCD {
        // Check if this skill already exists in Core Data
        let fetchRequest: NSFetchRequest<SkillCD> = SkillCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", skill.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingSkill = results.first {
                // Update existing skill if needed
                existingSkill.ownerId = ownerId
                return existingSkill
            }
        } catch {
            print("Error fetching skill: \(error)")
        }
        
        // Create new skill CD
        let skillCD = SkillCD(context: context)
        skillCD.id = skill.id
        skillCD.name = skill.name
        skillCD.skillDescription = skill.description
        skillCD.rarity = Int16(convertRarityToInt(skill.rarity))
        skillCD.skillType = String(describing: skill.type)
        skillCD.targetType = String(describing: skill.targetType)
        skillCD.elementType = skill.elementType.rawValue
        skillCD.basePower = Int16(skill.basePower)
        skillCD.cooldown = Int16(skill.cooldown)
        
        if let baseSkill = skill as? BaseSkill {
            skillCD.statusEffectChance = baseSkill.statusEffectChance
            if let statusEffect = baseSkill.statusEffect {
                skillCD.statusEffect = String(describing: statusEffect)
                skillCD.statusEffectDuration = Int16(baseSkill.statusEffectDuration)
            }
        }
        
        skillCD.ownerId = ownerId
        skillCD.dateAcquired = Date()
        
        return skillCD
    }
    
    // Create or update an EquipmentCD entity
    private func createOrUpdateEquipmentCD(from equipment: Equipment, ownerId: UUID) -> EquipmentCD {
        // Check if this equipment already exists in Core Data
        let fetchRequest: NSFetchRequest<EquipmentCD> = EquipmentCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", equipment.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingEquipment = results.first {
                // Update existing equipment if needed
                existingEquipment.ownerId = ownerId
                return existingEquipment
            }
        } catch {
            print("Error fetching equipment: \(error)")
        }
        
        // Create new equipment CD
        let equipmentCD = EquipmentCD(context: context)
        equipmentCD.id = equipment.id
        equipmentCD.name = equipment.name
        equipmentCD.equipmentDescription = equipment.description
        equipmentCD.rarity = Int16(convertRarityToInt(equipment.rarity))
        equipmentCD.elementType = equipment.elementType.rawValue
        
        // Serialize components
        var componentsArray: [[String: Any]] = []
//        for component in equipment.components {
//            if let statBoost = component as? StatBoostComponent {
//                let componentDict: [String: Any] = [
//                    "type": "statBoost",
//                    "statType": String(describing: statBoost.statType),
//                    "value": statBoost.value
//                ]
//                componentsArray.append(componentDict)
//            }
//        }
        
        equipmentCD.components = componentsArray as NSArray
        equipmentCD.ownerId = ownerId
        equipmentCD.dateAcquired = Date()
        
        return equipmentCD
    }
    
    // Draw items from gacha
    func createPlayerItems(from template: Toki, ownerId: UUID) -> Toki {
        // Randomly select some skills and equipment for this Toki
        let skills = selectRandomSkills(count: 2)
        let equipment = selectRandomEquipment(count: 1)
        
        // Create the player Toki with these items
        return createPlayerToki(from: template, with: skills, equipment: equipment, ownerId: ownerId)
    }
    
    // Select random skills for a newly drawn Toki
    private func selectRandomSkills(count: Int) -> [Skill] {
        let allSkills = Array(skillTemplates.values)
        guard !allSkills.isEmpty else { return [] }
        
        var selectedSkills: [Skill] = []
        for _ in 0..<min(count, allSkills.count) {
            if let randomSkill = allSkills.randomElement() {
                // Create a new instance with a unique ID
                if let baseSkill = randomSkill as? BaseSkill {
                    let newSkill = BaseSkill(
                        id: UUID(),
                        name: baseSkill.name,
                        description: baseSkill.description,
                        type: baseSkill.type,
                        targetType: baseSkill.targetType,
                        elementType: baseSkill.elementType,
                        basePower: baseSkill.basePower,
                        cooldown: baseSkill.cooldown,
                        statusEffectChance: baseSkill.statusEffectChance,
                        statusEffect: baseSkill.statusEffect,
                        statusEffectDuration: baseSkill.statusEffectDuration,
                        effectCalculator: baseSkill.effectCalculator,
                        rarity: baseSkill.rarity
                    )
                    selectedSkills.append(newSkill)
                }
            }
        }
        
        return selectedSkills
    }
    
    // Select random equipment for a newly drawn Toki
    private func selectRandomEquipment(count: Int) -> [Equipment] {
        let allEquipment = Array(equipmentTemplates.values)
        guard !allEquipment.isEmpty else { return [] }
        
        var selectedEquipment: [Equipment] = []
        for _ in 0..<min(count, allEquipment.count) {
            if let randomEquipment = allEquipment.randomElement() {
                // Create a new instance with a unique ID
                let newEquipment = Equipment(
                    id: UUID(),
                    name: randomEquipment.name,
                    description: randomEquipment.description,
                    elementType: randomEquipment.elementType,
                    components: randomEquipment.components,
                    rarity: randomEquipment.rarity
                )
                selectedEquipment.append(newEquipment)
            }
        }
        
        return selectedEquipment
    }
    
    // MARK: - Helper Methods
    
    private func convertStringToElement(_ str: String) -> ElementType {
        switch str.lowercased() {
        case "fire": return .fire
        case "water": return .water
        case "earth": return .earth
        case "air": return .air
        default: return .neutral
        }
    }
    
    private func convertIntToRarity(_ value: Int) -> ItemRarity {
        switch value {
        case 0: return .common
        case 1: return .rare
        case 2: return .legendary
        default: return .common
        }
    }
    
    private func convertRarityToInt(_ rarity: ItemRarity) -> Int {
        switch rarity {
        case .common: return 0
        case .rare: return 1
        case .legendary: return 2
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
