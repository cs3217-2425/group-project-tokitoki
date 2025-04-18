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
        let affectedStats: [String]?
        
        // For consumable
        let consumableType: String?
        let usageContext: String?
        let bonusExp: Int?
    }
}

extension JsonPersistenceManager {
    /// Persist this player's current equipment state.
    @discardableResult
    func savePlayerEquipment(_ equipmentComponent: EquipmentComponent,
                             playerId: UUID) -> Bool {
        // 1) Load others’ gear
        var allEquipment: [PlayerEquipmentEntry] = []
        if fileExists(filename: playerEquipmentsFileName),
           let existing: [PlayerEquipmentEntry] = loadFromJson(filename: playerEquipmentsFileName) {
            allEquipment = existing.filter { $0.equipment.ownerId != playerId }
        }

        // 2) Gather unique items (inventory + equipped)
        let combined: [Equipment] = equipmentComponent.inventory
            + equipmentComponent.equipped.values.map { $0 as Equipment }
        let uniqueEquipment = combined.reduce(into: [Equipment]()) { acc, eq in
            if !acc.contains(where: { $0.id == eq.id }) {
                acc.append(eq)
            }
        }

        // 3) Turn each into a JSON entry
        let newEntries: [PlayerEquipmentEntry] = uniqueEquipment.map { eq in
            if let nc = eq as? NonConsumableEquipment {
                return .init(
                    type: "nonConsumable",
                    equipment: .init(
                        id:              nc.id,
                        name:            nc.name,
                        description:     nc.description,
                        rarity:          nc.rarity,
                        equipmentType:   "nonConsumable",
                        ownerId:         playerId,

                        isEquipped:      equipmentComponent.equipped[nc.slot]?.id == nc.id,
                        slot:            nc.slot.rawValue,
                        buffValue:       nc.buff.value,
                        buffDescription: nc.buff.description,
                        affectedStats:   nc.buff.affectedStats.map { $0.rawValue },  // ← serialize array

                        consumableType:  nil,
                        usageContext:    nil,
                        bonusExp:        nil
                    )
                )

            } else if let c = eq as? ConsumableEquipment {
                // same as before...
                var typeString    = "consumable"
                var consumableType = "potion"
                var bonusExp: Int?

                if c.name.lowercased().contains("candy"),
                   let candyStrategy = c.effectStrategy as? UpgradeCandyEffectStrategy {
                    typeString    = "candy"
                    consumableType = "candy"
                    bonusExp       = candyStrategy.bonusExp
                } else if c.name.lowercased().contains("potion") {
                    consumableType = "potion"
                }

                let usageCtxString: String
                switch c.usageContext {
                case .battleOnly:        usageCtxString = "battleOnly"
                case .outOfBattleOnly:   usageCtxString = "outOfBattleOnly"
                case .battleOnlyPassive: usageCtxString = "battleOnlyPassive"
                case .anywhere:          usageCtxString = "anywhere"
                }

                return .init(
                    type: typeString,
                    equipment: .init(
                        id:              c.id,
                        name:            c.name,
                        description:     c.description,
                        rarity:          c.rarity,
                        equipmentType:   "consumable",
                        ownerId:         playerId,

                        isEquipped:      nil,
                        slot:            nil,
                        buffValue:       nil,
                        buffDescription: nil,
                        affectedStats:   nil,

                        consumableType:  consumableType,
                        usageContext:    usageCtxString,
                        bonusExp:        bonusExp
                    )
                )
            }

            // Fallback (shouldn’t happen)
            return .init(
                type: "nonConsumable",
                equipment: .init(
                    id:              eq.id,
                    name:            eq.name,
                    description:     eq.description,
                    rarity:          eq.rarity,
                    equipmentType:   "nonConsumable",
                    ownerId:         playerId,

                    isEquipped:      false,
                    slot:            "weapon",
                    buffValue:       0,
                    buffDescription: "Unknown",
                    affectedStats:   ["attack"],

                    consumableType:  nil,
                    usageContext:    nil,
                    bonusExp:        nil
                )
            )
        }

        // 4) Append only brand‑new entries
        let filtered = newEntries.filter { new in
            !allEquipment.contains { $0.equipment.id == new.equipment.id }
        }
        allEquipment.append(contentsOf: filtered)

        return saveToJson(allEquipment, filename: playerEquipmentsFileName)
    }

    /// Reconstruct this player's EquipmentComponent from disk.
    func loadPlayerEquipment(playerId: UUID) -> EquipmentComponent {
        guard let allEntries: [PlayerEquipmentEntry] =
                loadFromJson(filename: playerEquipmentsFileName) else {
            return EquipmentComponent()
        }

        let mine = allEntries.filter { $0.equipment.ownerId == playerId }
        var inventory: [Equipment] = []
        var equipped:   [EquipmentSlot: NonConsumableEquipment] = [:]

        for entry in mine {
            let info = entry.equipment

            if entry.type == "nonConsumable" {
                // Decode affectedStats array
                let statsArray = info.affectedStats?
                    .compactMap { EquipmentBuff.Stat(rawValue: $0) }
                    ?? []

                let buff = EquipmentBuff(
                    value:       info.buffValue ?? 0,
                    description: info.buffDescription ?? "",
                    affectedStats: statsArray
                )

                let slotEnum = EquipmentSlot(rawValue: info.slot ?? "") ?? .weapon
                let nc = NonConsumableEquipment(
                    id:          info.id,
                    name:        info.name,
                    description: info.description,
                    rarity:      info.rarity,
                    buff:        buff,
                    slot:        slotEnum
                )

                if info.isEquipped == true {
                    equipped[slotEnum] = nc
                }
                inventory.append(nc)

            } else {
                // Consumable path (same as before)…
                let usage: ConsumableUsageContext
                switch info.usageContext?.lowercased() {
                case "battleonly":      usage = .battleOnly
                case "outofbattleonly": usage = .outOfBattleOnly
                case "battleonlypassive": usage = .battleOnlyPassive
                default:                usage = .anywhere
                }

                var strategy: ConsumableEffectStrategy =
                    PotionEffectStrategy(effectCalculators: [HealCalculator(healPower: 100)])
                if info.consumableType == "candy" {
                    strategy = UpgradeCandyEffectStrategy(bonusExp: info.bonusExp ?? 100)
                }

                let con = ConsumableEquipment(
                    id:             info.id,
                    name:           info.name,
                    description:    info.description,
                    rarity:         info.rarity,
                    effectStrategy: strategy,
                    usageContext:   usage
                )
                inventory.append(con)
            }
        }

        return EquipmentComponent(inventory: inventory, equipped: equipped)
    }

    /// Remove all entries for this player
    @discardableResult
    func deletePlayerEquipment(playerId: UUID) -> Bool {
        guard let allEntries: [PlayerEquipmentEntry] =
                loadFromJson(filename: playerEquipmentsFileName) else {
            return true
        }
        let filtered = allEntries.filter { $0.equipment.ownerId != playerId }
        return saveToJson(filtered, filename: playerEquipmentsFileName)
    }
}
