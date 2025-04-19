//
//  JsonPersistanceManager+Equipment.swift
//  TokiToki
//
//  Created by Wh Kang on 11/4/25.
//

import Foundation

/// Mirrors the structure of player_equipments.json
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
        var allEntries: [PlayerEquipmentEntry] = []
        if fileExists(filename: playerEquipmentsFileName),
           let existing: [PlayerEquipmentEntry] = loadFromJson(filename: playerEquipmentsFileName) {
            allEntries = existing.filter { $0.equipment.ownerId != playerId }
        }

        // 2) Generate new entries from this player’s equipment
        let newEntries = buildPlayerEquipmentEntries(
            from: equipmentComponent,
            playerId: playerId
        )

        // 3) Append only brand‑new entries
        let filtered = newEntries.filter { new in
            !allEntries.contains { $0.equipment.id == new.equipment.id }
        }
        allEntries.append(contentsOf: filtered)

        return saveToJson(allEntries, filename: playerEquipmentsFileName)
    }
    
    private func buildPlayerEquipmentEntries(from component: EquipmentComponent,
                                             playerId: UUID) -> [PlayerEquipmentEntry] {
        // Combine and deduplicate
        let combined = component.inventory + component.equipped.values
        let uniqueEquipment = combined.reduce(into: [Equipment]()) { acc, eq in
            if !acc.contains(where: { $0.id == eq.id }) {
                acc.append(eq)
            }
        }

        // EquipmentID → Slot map
        let slotMap = component.equipped.reduce(into: [UUID: EquipmentSlot]()) { dict, pair in
            dict[pair.value.id] = pair.key
        }

        return uniqueEquipment.map { eq in
            if let nc = eq as? NonConsumableEquipment {
                let isEquipped = component.equipped[nc.slot]?.id == nc.id
                return .init(
                    type: "nonConsumable",
                    equipment: .init(
                        id: nc.id,
                        name: nc.name,
                        description: nc.description,
                        rarity: nc.rarity,
                        equipmentType: "nonConsumable",
                        ownerId: playerId,

                        isEquipped: isEquipped,
                        slot: nc.slot.rawValue,
                        buffValue: nc.buff.value,
                        buffDescription: nc.buff.description,
                        affectedStats: nc.buff.affectedStats.map { $0.rawValue },

                        consumableType: nil,
                        usageContext: nil,
                        bonusExp: nil
                    )
                )
            } else if let c = eq as? ConsumableEquipment {
                let equippedSlot = slotMap[c.id]?.rawValue
                let isEquipped = slotMap[c.id] != nil

                var typeString = "consumable"
                var consumableType = "potion"
                var bonusExp: Int?

                if c.name.lowercased().contains("candy"),
                   let strat = c.effectStrategy as? UpgradeCandyEffectStrategy {
                    typeString = "candy"
                    consumableType = "candy"
                    bonusExp = strat.bonusExp
                }
                else if c.name.lowercased().contains("revival ring") {
                    typeString = "revivalRing"
                    consumableType = "revivalRing"
                }

                let usageCtxString: String = {
                    switch c.usageContext {
                    case .battleOnly:        return "battleOnly"
                    case .outOfBattleOnly:   return "outOfBattleOnly"
                    case .battleOnlyPassive: return "battleOnlyPassive"
                    case .anywhere:          return "anywhere"
                    }
                }()

                return .init(
                    type: typeString,
                    equipment: .init(
                        id: c.id,
                        name: c.name,
                        description: c.description,
                        rarity: c.rarity,
                        equipmentType: "consumable",
                        ownerId: playerId,

                        isEquipped: isEquipped,
                        slot: equippedSlot,
                        buffValue: nil,
                        buffDescription: nil,
                        affectedStats: nil,

                        consumableType: consumableType,
                        usageContext: usageCtxString,
                        bonusExp: bonusExp
                    )
                )
            }

            // Fallback case
            return .init(
                type: "nonConsumable",
                equipment: .init(
                    id: eq.id,
                    name: eq.name,
                    description: eq.description,
                    rarity: eq.rarity,
                    equipmentType: "nonConsumable",
                    ownerId: playerId,

                    isEquipped: false,
                    slot: EquipmentSlot.weapon.rawValue,
                    buffValue: 0,
                    buffDescription: "Unknown",
                    affectedStats: ["attack"],

                    consumableType: nil,
                    usageContext: nil,
                    bonusExp: nil
                )
            )
        }
    }


    /// Reconstruct this player's EquipmentComponent from disk.
    func loadPlayerEquipment(playerId: UUID) -> EquipmentComponent {
        guard let allEntries: [PlayerEquipmentEntry] =
                loadFromJson(filename: playerEquipmentsFileName) else {
            return EquipmentComponent()
        }

        let mine = allEntries.filter { $0.equipment.ownerId == playerId }
        var inventory: [Equipment] = []
        var equipped:   [EquipmentSlot: Equipment] = [:]

        for entry in mine {
            let info = entry.equipment

            if entry.type == "nonConsumable" {
                // Decode buff
                let stats = info.affectedStats?
                    .compactMap { EquipmentBuff.Stat(rawValue: $0) }
                    ?? []
                let buff = EquipmentBuff(
                    value:         info.buffValue ?? 0,
                    description:   info.buffDescription ?? "",
                    affectedStats: stats
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

                // ONLY append to equipped _or_ inventory — never both
                if info.isEquipped == true {
                    equipped[slotEnum] = nc
                } else {
                    inventory.append(nc)
                }

            } else {
                // Consumable path
                let usage: ConsumableUsageContext = {
                    switch info.usageContext?.lowercased() {
                    case "battleonly":       return .battleOnly
                    case "outofbattleonly":  return .outOfBattleOnly
                    case "battleonlypassive":return .battleOnlyPassive
                    default:                 return .anywhere
                    }
                }()
                
                let defaultStrategy = PotionEffectStrategy(effectCalculators: [HealCalculator(healPower: 100)])
                var strategy: ConsumableEffectStrategy
                if info.consumableType == "candy" {
                    strategy = UpgradeCandyEffectStrategy(bonusExp: info.bonusExp ?? 100)
                } else {
                    strategy = consumableToEffectStrategy[info.consumableType ?? ""] ?? defaultStrategy
                }

                var con = ConsumableEquipment(
                    id:             info.id,
                    name:           info.name,
                    description:    info.description,
                    rarity:         info.rarity,
                    effectStrategy: strategy,
                    usageContext:   usage
                )
                
                if info.isEquipped == true,
                   let rawSlot = info.slot,
                   let slotEnum = EquipmentSlot(rawValue: rawSlot) {
                    equipped[slotEnum] = con
                } else {
                    inventory.append(con)
                }
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
