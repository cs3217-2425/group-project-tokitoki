//
//  TokiDisplay+Load.swift
//  TokiToki
//
//  Created by Wh Kang on 6/4/25.
//

import Foundation

struct PlayerEquipmentWrapper: Decodable { let type: String; let equipment: EquipmentJSON }

extension TokiDisplay {
    func saveTokiState() {
        // Save the current state of Toki using JsonPersistenceManager
        let jsonPersistenceManager = JsonPersistenceManager()
        let playerRepository = PlayerRepository(persistenceManager: jsonPersistenceManager)
        var player = PlayerManager.shared.getOrCreatePlayer()

        // Update the player's state with the current in-memory data from TokiDisplay.
        // This includes the currently loaded Tokis and Equipment.
        player.ownedTokis = TokiDisplay.shared.allTokis
        player.ownedEquipments = TokiDisplay.shared.equipmentFacade.equipmentComponent

        // Optionally, update additional properties like owned skills if needed:
        // player.ownedSkills = TokiDisplay.shared.allSkills

        // Persist the updated player state.
        playerRepository.savePlayer(player)
    }

    /// Load Tokis, Skills, and Equipment from JSON persistence.
    func loadAllData() {
        // Use JsonPersistenceManager and PlayerRepository to load the current player.
        let persistenceManager = JsonPersistenceManager()
        let playerRepository = PlayerRepository(persistenceManager: persistenceManager)
        guard let player = playerRepository.getPlayer() else {
            print("No player data found in JsonPersistenceManager.")
            return
        }

        loadTokisFromJSON(using: persistenceManager, for: player)
        loadSkillsFromJSON()
        loadEquipmentsFromJSON(using: persistenceManager, for: player)
        loadCraftingRecipesFromJSON()
    }

    // Load Tokis from the JSON file using the persistence manager.
    private func loadTokisFromJSON(using persistenceManager: JsonPersistenceManager, for player: Player) {
        if let loadedTokis = persistenceManager.loadPlayerTokis(playerId: player.id) {
            self.allTokis = loadedTokis
            if let firstToki = loadedTokis.first {
                self.toki = firstToki
            }
        } else {
            print("Failed to load tokis for player \(player.name)")
        }
    }

    // The skills file remains the same and is loaded from bundle.
    private func loadSkillsFromJSON() {
        guard let url = Bundle.main.url(forResource: "Skills", withExtension: "json") else {
            print("Skills.json not found in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(SkillsWrapper.self, from: data)
            let factory = SkillsFactory()
            self.allSkills = decoded.skills.compactMap { factory.createSkill(from: $0) }
        } catch {
            print("Failed to parse Skills.json: \(error)")
        }
    }

    // Load Equipment from JSON using the persistence manager.
    func loadEquipmentsFromJSON(using persistenceManager: JsonPersistenceManager, for player: Player) {
        if let equipmentComponent = persistenceManager.loadPlayerEquipment(playerId: player.id) {
            self.equipmentFacade.equipmentComponent = equipmentComponent
        } else {
            print("Failed to load equipments for player \(player.name)")
        }
    }

    private func loadCraftingRecipesFromJSON() {
        guard let url = Bundle.main.url(forResource: "CraftingRecipes", withExtension: "json") else {
            print("CraftingRecipes.json not found in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(CraftingRecipesWrapper.self, from: data)
            let repo = EquipmentRepository.shared

            for recipeJson in decoded.recipes {
                var recipe: CraftingRecipe?
                let type = recipeJson.type.lowercased()

                if type == "consumable" {
                    recipe = CraftingRecipe(requiredEquipmentIdentifiers: recipeJson.requiredEquipmentIdentifiers) { (equipments: [Equipment]) in
                        if let eq1 = equipments[0] as? ConsumableEquipment,
                           let eq2 = equipments[1] as? ConsumableEquipment,
                           let strat1 = eq1.effectStrategy as? PotionEffectStrategy,
                           let strat2 = eq2.effectStrategy as? PotionEffectStrategy {

                            let newCalculators = strat1.effectCalculators + strat2.effectCalculators
                            let newStrategy = PotionEffectStrategy(effectCalculators: newCalculators)

                            // Convert usageContext; default to .anywhere if missing.
                            let usage: ConsumableUsageContext = {
                                if let usageStr = recipeJson.usageContext,
                                   let converted = self.convertUsageContext(usageStr) {
                                    return converted
                                } else {
                                    return .anywhere
                                }
                            }()

                            return repo.createConsumableEquipment(name: recipeJson.resultName,
                                                                  description: recipeJson.description,
                                                                  rarity: max(eq1.rarity, eq2.rarity) + recipeJson.rarityIncrement,
                                                                  effectStrategy: newStrategy,
                                                                  usageContext: usage)
                        }
                        return nil
                    }
                } else if type == "nonconsumable" {
                    guard let slotStr = recipeJson.slot, let slot = EquipmentSlot(rawValue: slotStr) else {
                        print("Invalid or missing slot for nonconsumable recipe: \(recipeJson.resultName)")
                        continue
                    }
                    recipe = CraftingRecipe(requiredEquipmentIdentifiers: recipeJson.requiredEquipmentIdentifiers) { (equipments: [Equipment]) in
                        if let eq1 = equipments[0] as? NonConsumableEquipment,
                           let eq2 = equipments[1] as? NonConsumableEquipment {
                            let combinedBuff = EquipmentBuff(value: eq1.buff.value + eq2.buff.value,
                                                             description: "Combined buff",
                                                             affectedStat: "attack")
                            return NonConsumableEquipment(id: UUID(), name: recipeJson.resultName,
                                                          description: recipeJson.description,
                                                          rarity: max(eq1.rarity, eq2.rarity) + recipeJson.rarityIncrement,
                                                          buff: combinedBuff,
                                                          slot: slot)
                        }
                        return nil
                    }
                } else {
                    print("Unknown equipment type in recipe: \(recipeJson.type)")
                }

                if let recipe = recipe {
                    ServiceLocator.shared.craftingManager.register(recipe: recipe)
                }
            }
        } catch {
            print("Failed to load crafting recipes: \(error)")
        }
    }

    // --- Helper converter functions ---

    private func convertUsageContext(_ raw: String) -> ConsumableUsageContext? {
        switch raw.lowercased() {
        case "battleonly", "battle only":
            return .battleOnly
        case "outofbattleonly", "out of battle only":
            return .outOfBattleOnly
        case "anywhere":
            return .anywhere
        default:
            return nil
        }
    }

    private func convertToToki(_ json: TokiJSON) -> Toki {
        let rarityEnum = ItemRarity(intValue: json.rarity) ?? .common
        let elementTypes = json.elementType.compactMap { ElementType.fromString($0) }

        let stats = TokiBaseStats(
            hp: json.baseStats.hp,
            attack: json.baseStats.attack,
            defense: json.baseStats.defense,
            speed: json.baseStats.speed,
            heal: json.baseStats.heal,
            exp: json.baseStats.exp
        )

        return Toki(
            name: json.name,
            rarity: rarityEnum,
            baseStats: stats,
            skills: [],
            equipments: [],
            elementType: elementTypes,
            level: json.level
        )
    }

    private func convertToEquipment(_ json: EquipmentJSON) -> Equipment? {
        let repo = EquipmentRepository.shared
        let rarity = json.rarity
        let desc = json.description
        let usageContext = json.usageContext

        if json.equipmentType == "consumable", let strategyInfo = json.effectStrategy {
            let strategy: ConsumableEffectStrategy
            switch strategyInfo.type.lowercased() {
            case "potion":
                let calculators = strategyInfo.effectCalculators?.map { $0.toEffectCalculator() } ?? []
                strategy = PotionEffectStrategy(effectCalculators: calculators)
            case "upgradecandy":
                let bonus = strategyInfo.bonusExp ?? 0
                strategy = UpgradeCandyEffectStrategy(bonusExp: bonus)
            default:
                strategy = UpgradeCandyEffectStrategy(bonusExp: 0)
            }

            return repo.createConsumableEquipment(
                name: json.name,
                description: desc,
                rarity: rarity,
                effectStrategy: strategy,
                usageContext: convertUsageContext(usageContext ?? "anywhere") ?? .anywhere
            )
        } else if json.equipmentType == "nonConsumable", let buffInfo = json.buff, let slotName = json.slot {
            let buff = EquipmentBuff(
                value: buffInfo.value,
                description: buffInfo.description,
                affectedStat: buffInfo.affectedStat
            )
            let slotEnum = EquipmentSlot(rawValue: slotName) ?? .custom

            return repo.createNonConsumableEquipment(
                name: json.name,
                description: desc,
                rarity: rarity,
                buff: buff,
                slot: slotEnum
            )
        }
        return nil
    }

    // Example converters for skill target type and status effect.
    private func convertTargetType(_ raw: String) -> TargetType {
        switch raw.lowercased() {
        case "singleenemy": return .singleEnemy
        case "allallies": return .allAllies
        case "allenemies": return .allEnemies
        case "ownself": return .ownself
        default: return .singleEnemy
        }
    }

    private func convertStatusEffect(_ raw: String?) -> StatusEffectType {
        guard let raw = raw else { return .stun }
        switch raw.lowercased() {
        case "burn": return .burn
        case "paralysis": return .paralysis
        default: return .stun
        }
    }

}
