//
//  TokiDisplay+Load.swift
//  TokiToki
//
//  Created by Wh Kang on 6/4/25.
//

import Foundation

struct PlayerEquipmentWrapper: Decodable {
    let type: String
    let equipment: EquipmentJSON
}

extension TokiDisplay {
    func saveTokiState() {
        let persistence = JsonPersistenceManager()
        let player = PlayerManager.shared.getOrCreatePlayer()
        _ = persistence.savePlayerTokis(self.allTokis, playerId: player.id)
        _ = persistence.savePlayerEquipment(self.equipmentFacade.equipmentComponent, playerId: player.id)
    }

    func loadAllData() {
        let persistence = JsonPersistenceManager()
        let repo = PlayerRepository(persistenceManager: persistence)
        guard let player = repo.getPlayer() else {
            logger.logError("No player data found.")
            return
        }

        loadTokisFromJSON(using: persistence, for: player)
        loadSkillsFromJSON()
        loadEquipmentsFromJSON(using: persistence, for: player)
        loadCraftingRecipesFromJSON()
    }

    private func loadTokisFromJSON(using persistence: JsonPersistenceManager, for player: Player) {
        if let tokis = persistence.loadPlayerTokis(playerId: player.id) {
            self.allTokis = tokis
            if let first = tokis.first { self.toki = first }
        } else {
            logger.log("Failed to load tokis for \(player.name)")
        }
    }

    private func loadSkillsFromJSON() {
        guard let url = Bundle.main.url(forResource: "Skills", withExtension: "json") else {
            logger.log("Skills.json not found.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let wrapper = try JSONDecoder().decode(SkillsWrapper.self, from: data)
            let factory = SkillsFactory()
            self.allSkills = wrapper.skills.compactMap { factory.createSkill(from: $0) }
        } catch {
            logger.log("Skills parsing error: \(error)")
        }
    }

    func loadEquipmentsFromJSON(using persistence: JsonPersistenceManager, for player: Player) {
        // 1) Pull component straight from disk
        let component = persistence.loadPlayerEquipment(playerId: player.id)
        self.equipmentFacade.equipmentComponent = component

        // 2) Reconstruct your Toki.equipments in slot order
        let slotOrder: [EquipmentSlot] = [.weapon, .armor, .accessory, .custom]
        self.toki.equipments = slotOrder.compactMap { component.equipped[$0] }
    }

    private func loadCraftingRecipesFromJSON() {
        guard let url = Bundle.main.url(forResource: "CraftingRecipes", withExtension: "json") else {
            logger.log("CraftingRecipes.json not found.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let wrapper = try JSONDecoder().decode(CraftingRecipesWrapper.self, from: data)
            let repo = EquipmentRepository.shared

            for recipeJson in wrapper.recipes {
                var recipe: CraftingRecipe?
                let typeLower = recipeJson.type.lowercased()

                if typeLower == "consumable" {
                    recipe = CraftingRecipe(requiredEquipmentIdentifiers: recipeJson.requiredEquipmentIdentifiers) { equipments in
                        guard
                            let eq1 = equipments[0] as? ConsumableEquipment,
                            let eq2 = equipments[1] as? ConsumableEquipment,
                            let strat1 = eq1.effectStrategy as? PotionEffectStrategy,
                            let strat2 = eq2.effectStrategy as? PotionEffectStrategy
                        else {
                            return nil
                        }
                        let newCalc = strat1.effectCalculators + strat2.effectCalculators
                        let newStrat = PotionEffectStrategy(effectCalculators: newCalc)
                        let usage: ConsumableUsageContext = {
                            if let raw = recipeJson.usageContext,
                               let ctx = self.convertUsageContext(raw) {
                                return ctx
                            }
                            return .anywhere
                        }()
                        return repo.createConsumableEquipment(
                            name: recipeJson.resultName,
                            description: recipeJson.description,
                            rarity: max(eq1.rarity, eq2.rarity) + recipeJson.rarityIncrement,
                            effectStrategy: newStrat,
                            usageContext: usage
                        )
                    }

                } else if typeLower == "nonconsumable" {
                    guard let slotRaw = recipeJson.slot,
                          let slot = EquipmentSlot(rawValue: slotRaw) else {
                        logger.logError("Invalid slot for recipe \(recipeJson.resultName)")
                        continue
                    }
                    recipe = CraftingRecipe(requiredEquipmentIdentifiers: recipeJson.requiredEquipmentIdentifiers) { equipments in
                        guard
                            let eq1 = equipments[0] as? NonConsumableEquipment,
                            let eq2 = equipments[1] as? NonConsumableEquipment
                        else {
                            return nil
                        }
                        let combinedBuff = EquipmentBuff(
                            value: eq1.buff.value + eq2.buff.value,
                            description: "Combined buff",
                            affectedStats: [.attack]
                        )
                        return NonConsumableEquipment(
                            id: UUID(),
                            name: recipeJson.resultName,
                            description: recipeJson.description,
                            rarity: max(eq1.rarity, eq2.rarity) + recipeJson.rarityIncrement,
                            buff: combinedBuff,
                            slot: slot
                        )
                    }
                } else {
                    logger.log("Unknown recipe type \(recipeJson.type)")
                }

                if let rec = recipe {
                    ServiceLocator.shared.craftingManager.register(recipe: rec)
                }
            }
        } catch {
            logger.logError("CraftingRecipes parsing error: \(error)")
        }
    }

    private func convertUsageContext(_ raw: String) -> ConsumableUsageContext? {
        switch raw.lowercased() {
        case "battleonly", "battle only": return .battleOnly
        case "outofbattleonly", "out of battle only": return .outOfBattleOnly
        case "battleonlypassive": return .battleOnlyPassive
        case "anywhere": return .anywhere
        default: return nil
        }
    }

    private func convertToToki(_ json: TokiJSON) -> Toki {
        let rarity = ItemRarity(intValue: json.rarity) ?? .common
        let elems = json.elementType.compactMap { ElementType.fromString($0) }
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
            rarity: rarity,
            baseStats: stats,
            skills: [],
            equipments: [],
            elementType: elems,
            level: json.level
        )
    }

    private func convertToEquipment(_ json: EquipmentJSON) -> Equipment? {
        let repo = EquipmentRepository.shared
        if json.equipmentType == "consumable",
           let stratInfo = json.effectStrategy {
            let strategy: ConsumableEffectStrategy
            switch stratInfo.type.lowercased() {
            case "potion":
                let calculators = stratInfo.effectCalculators?.map { $0.toEffectCalculator() } ?? []
                strategy = PotionEffectStrategy(effectCalculators: calculators)
            case "upgradecandy":
                strategy = UpgradeCandyEffectStrategy(bonusExp: stratInfo.bonusExp ?? 0)
            default:
                strategy = UpgradeCandyEffectStrategy(bonusExp: 0)
            }
            return repo.createConsumableEquipment(
                name: json.name,
                description: json.description,
                rarity: json.rarity,
                effectStrategy: strategy,
                usageContext: convertUsageContext(json.usageContext ?? "") ?? .anywhere
            )
        } else if json.equipmentType == "nonConsumable",
                  let buffInfo = json.buff,
                  let slotRaw = json.slot {
            let statsArray = buffInfo.affectedStats.compactMap { EquipmentBuff.Stat(rawValue: $0) }
            let buff = EquipmentBuff(
                value: buffInfo.value,
                description: buffInfo.description,
                affectedStats: statsArray
            )
            let slot = EquipmentSlot(rawValue: slotRaw) ?? .custom
            return repo.createNonConsumableEquipment(
                name: json.name,
                description: json.description,
                rarity: json.rarity,
                buff: buff,
                slot: slot
            )
        }
        return nil
    }
}
