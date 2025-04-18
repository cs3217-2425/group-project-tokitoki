//
//  JsonPersistanceManager+Equipment.swift
//  TokiToki
//
//  Created by Wh Kang on 11/4/25.
//

import Foundation

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

extension JsonPersistenceManager {
    /// Save player's equipment to JSON
    func savePlayerEquipment(_ equipmentComponent: EquipmentComponent, playerId: UUID) -> Bool {
        // 1) Load existing equipment from player_equipments.json
        var allEquipment: [PlayerEquipmentEntry] = []
        if fileExists(filename: playerEquipmentsFileName),
           let existing: [PlayerEquipmentEntry] = loadFromJson(filename: playerEquipmentsFileName) {
            // Keep equipment owned by other players
            allEquipment = existing.filter { $0.equipment.ownerId != playerId }
        }

        // 2) Combine inventory and equipped items, removing duplicates
        let combinedEquipment = equipmentComponent.inventory + equipmentComponent.equipped.values.map { $0 as Equipment }
        let allPlayerEquipment = combinedEquipment.reduce(into: [Equipment]()) { result, eq in
            if !result.contains(where: { $0.id == eq.id }) {
                result.append(eq)
            }
        }

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
                var bonusExp: Int?

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
                case .battleOnlyPassive: usageCtxString = "battleOnlyPassive"
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

        // 4) Filter duplicate entries based on equipment id
        let filteredNewEntries = newEntries.filter { newEntry in
            return !allEquipment.contains(where: { $0.equipment.id == newEntry.equipment.id })
        }
        allEquipment.append(contentsOf: filteredNewEntries)
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
                    id: eqInfo.id,
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
                    inventory.append(nc) // still part of inventory
                    print("[JsonPersistenceManager] Equipped: \(nc.name) in slot \(slotEnum)")
                } else {
                    inventory.append(nc)
                    print("[JsonPersistenceManager] Added to inventory: \(nc.name)")
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
                var strategy: ConsumableEffectStrategy = PotionEffectStrategy(effectCalculators: [HealCalculator(healPower: 100)])
                if eqInfo.consumableType == "candy" {
                    let bonus = eqInfo.bonusExp ?? 100
                    strategy = UpgradeCandyEffectStrategy(bonusExp: bonus)
                }

                var con = ConsumableEquipment(
                    id: eqInfo.id,
                    name: eqInfo.name,
                    description: eqInfo.description,
                    rarity: eqInfo.rarity,
                    effectStrategy: strategy,
                    usageContext: usage
                )
                // Consumables always go to inventory (no concept of “equipped”)
                inventory.append(con)
                print("[JsonPersistenceManager] Added to inventory: \(con.name)")
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
}
