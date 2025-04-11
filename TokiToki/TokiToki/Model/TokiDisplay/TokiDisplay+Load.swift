//
//  TokiDisplay+Load.swift
//  TokiToki
//
//  Created by Wh Kang on 6/4/25.
//

import Foundation

extension TokiDisplay {
    // MARK: - JSON Loading
    
    /// Load Tokis, Skills, and Equipment from local JSON files.
    /// Adapt the file paths or decoding strategy as appropriate.
    func loadAllData() {
        loadTokisFromJSON()
        loadSkillsFromJSON()
        loadCraftingRecipesFromJSON()
    }
    
    private func loadTokisFromJSON() {
        guard let url = Bundle.main.url(forResource: "Tokis", withExtension: "json") else {
            print("Tokis.json not found in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(TokisWrapper.self, from: data)
            self.allTokis = decoded.tokis.map { convertToToki($0) }
            // Update the current Toki if available.
            if let firstToki = self.allTokis.first {
                self.toki = firstToki
            }
        } catch {
            print("Failed to parse Tokis.json: \(error)")
        }
    }
    
    private func loadSkillsFromJSON() {
        guard let url = Bundle.main.url(forResource: "Skills", withExtension: "json") else {
            print("Skills.json not found in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(SkillsWrapper.self, from: data)
            //            self.allSkills = decoded.skills.map { convertToSkill($0) }
            //            // Update the current Toki's skills inventory.
            //            self.toki.skills = self.allSkills
        } catch {
            print("Failed to parse Skills.json: \(error)")
        }
    }
    
    func loadEquipmentsFromJSON() {
        guard let url = Bundle.main.url(forResource: "Equipments", withExtension: "json") else {
            print("Equipments.json not found in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(EquipmentsWrapper.self, from: data)
            let component = TokiDisplay.shared.equipmentFacade.equipmentComponent
            component.inventory = decoded.equipment.compactMap { convertToEquipment($0) }
            
            self.equipmentFacade.equipmentComponent = component
        } catch {
            print("Failed to parse Equipments.json: \(error)")
        }
    }
    
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
                            return NonConsumableEquipment(name: recipeJson.resultName,
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
    
    private func convertToToki(_ json: TokiJSON) -> Toki {
         // Use the new ItemRarity initializer.
         let rarityEnum = ItemRarity(intValue: json.rarity) ?? .common
         // Convert string to ElementType using fromString.
         let elementEnum = ElementType.fromString(json.elementType) ?? .fire
         
         let stats = TokiBaseStats(hp: json.baseHealth,
                                   attack: json.baseAttack,
                                   defense: json.baseDefense,
                                   speed: json.baseSpeed,
                                   heal: json.baseHeal,
                                   exp: json.baseExp)
         
         // Create a Toki with empty skills and equipment; attach later as needed.
         return Toki(name: json.name,
                     rarity: rarityEnum,
                     baseStats: stats,
                     skills: [],
                     equipments: [],
                     elementType: [elementEnum],
                     level: 1)
     }
    
//    private func convertToSkill(_ json: SkillJSON) -> Skill {
//         // Use the new ElementType conversion.
//         let elemType = ElementType.fromString(json.elementType) ?? .neutral
//
//         let factory = SkillFactory()
//
//         switch json.skillType.lowercased() {
//         case "attack":
//             return factory.createAttackSkill(
//                 name: json.name,
//                 description: json.description,
//                 elementType: elemType,
//                 basePower: json.basePower,
//                 cooldown: json.cooldown,
//                 targetType: convertTargetType(json.targetType),
//                 statusEffect: convertStatusEffect(json.statusEffect),
//                 statusEffectChance: Double(json.statusEffectChance),
//                 statusEffectDuration: json.statusEffectDuration
//             )
//         case "heal":
//             return factory.createHealSkill(
//                 name: json.name,
//                 description: json.description,
//                 basePower: json.basePower,
//                 cooldown: json.cooldown,
//                 targetType: convertTargetType(json.targetType)
//             )
//         case "defend":
//             return factory.createDefenseSkill(
//                name: json.name,
//                description: json.description,
//                basePower: json.basePower,
//                cooldown: json.cooldown,
//                targetType: convertTargetType(json.targetType)
//             )
//         default:
//             return factory.createAttackSkill(
//                 name: json.name,
//                 description: json.description,
//                 elementType: elemType,
//                 basePower: json.basePower,
//                 cooldown: json.cooldown,
//                 targetType: .singleEnemy,
//                 statusEffect: .none,
//                 statusEffectChance: 0.0,
//                 statusEffectDuration: 0
//             )
//         }
//     }
     
    private func convertToEquipment(_ json: EquipmentJSON) -> Equipment? {
         let repo = EquipmentRepository.shared
         let rarity = json.rarity
         let desc = json.description
         let usageContext = json.usageContext
         
         if json.equipmentType == "consumable", let strategyInfo = json.effectStrategy {
             let strategy: ConsumableEffectStrategy
             switch strategyInfo.type.lowercased() {
             case "potion":
                 let effectCalculators = strategyInfo.effectCalculators ?? []
                 strategy = PotionEffectStrategy(effectCalculators: effectCalculators)
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
             let buff = EquipmentBuff(value: buffInfo.value,
                                      description: buffInfo.description,
                                      affectedStat: buffInfo.affectedStat)
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
    
    /// Example converters for skill target type and status effect
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
