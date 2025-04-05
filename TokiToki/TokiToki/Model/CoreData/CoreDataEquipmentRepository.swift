//
//  CoreDataEquipmentRepository.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 5/4/25.
//


//
//  CoreDataEquipmentRepository.swift
//  TokiToki
//

import CoreData
import Foundation

class CoreDataEquipmentRepository {
    private let context: NSManagedObjectContext
    private let equipmentFactory = EquipmentRepository.shared
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Save Operations
    
    /// Save equipment to Core Data
    func saveEquipment(_ equipment: Equipment, ownerId: UUID? = nil) -> EquipmentCD {
        // Create the equipment entity
        let equipmentCD = EquipmentCD(context: context)
        
        // Set basic properties
        equipmentCD.id = equipment.id
        equipmentCD.name = equipment.name
        equipmentCD.desc = equipment.description
        equipmentCD.rarity = Int32(equipment.rarity)
        equipmentCD.ownerId = ownerId
        equipmentCD.dateAcquired = Date()
        
        // Set type-specific properties
        switch equipment.equipmentType {
        case .consumable:
            equipmentCD.equipmentType = "consumable"
            
            if let consumable = equipment as? ConsumableEquipment {
                if let potionStrategy = consumable.effectStrategy as? PotionEffectStrategy {
                    equipmentCD.effect_type = "potion"
                    equipmentCD.effect_buffValue = Int32(potionStrategy.buffValue)
                    equipmentCD.effect_duration = Int32(potionStrategy.duration)
                } else if let candyStrategy = consumable.effectStrategy as? UpgradeCandyEffectStrategy {
                    equipmentCD.effect_type = "upgradeCandy"
                    equipmentCD.effect_bonusExp = Int32(candyStrategy.bonusExp)
                }
            }
            
        case .nonConsumable:
            equipmentCD.equipmentType = "nonConsumable"
            
            if let nonConsumable = equipment as? NonConsumableEquipment {
                equipmentCD.buff_value = Int32(nonConsumable.buff.value)
                equipmentCD.buff_desc = nonConsumable.buff.description
                equipmentCD.buff_affectedStat = nonConsumable.buff.affectedStat
                
                // Store slot information if available
                if let slotString = nonConsumableSlotToString(nonConsumable.slot) {
                    // This would require adding a slot attribute to the EquipmentCD entity
                    // equipmentCD.slot = slotString
                }
            }
        }
        
        // Save context
        DataManager.shared.saveContext(context)
        
        return equipmentCD
    }
    
    // MARK: - Load Operations
    
    /// Load equipment from Core Data
    func loadEquipment(from equipmentCD: EquipmentCD) -> Equipment {
        let equipmentTypeString = equipmentCD.equipmentType ?? "nonConsumable"
        
        if equipmentTypeString == "consumable" {
            // Create consumable equipment
            let effectTypeString = equipmentCD.effect_type ?? "potion"
            let effectStrategy: ConsumableEffectStrategy
            
            switch effectTypeString {
            case "potion":
                let buffValue = Int(equipmentCD.effect_buffValue)
                let duration = TimeInterval(equipmentCD.effect_duration)
                effectStrategy = PotionEffectStrategy(buffValue: buffValue, duration: duration)
                
            case "upgradeCandy":
                let bonusExp = Int(equipmentCD.effect_bonusExp)
                effectStrategy = UpgradeCandyEffectStrategy(bonusExp: bonusExp)
                
            default:
                // Default to potion with some values
                effectStrategy = PotionEffectStrategy(buffValue: 10, duration: 30.0)
            }
            
            // Use factory to create the equipment
            return equipmentFactory.createConsumableEquipment(
                name: equipmentCD.name ?? "Unknown Equipment",
                description: equipmentCD.desc ?? "",
                rarity: Int(equipmentCD.rarity),
                effectStrategy: effectStrategy
            )
        } else {
            // Create non-consumable equipment
            let buffValue = Int(equipmentCD.buff_value)
            let buffDescription = equipmentCD.buff_desc ?? "Default buff"
            let affectedStat = equipmentCD.buff_affectedStat ?? "attack"
            
            let buff = EquipmentBuff(
                value: buffValue,
                description: buffDescription,
                affectedStat: affectedStat
            )
            
            // Determine slot (default to weapon if not specified)
            let slot = EquipmentSlot.weapon
            
            // Use factory to create the equipment
            return equipmentFactory.createNonConsumableEquipment(
                name: equipmentCD.name ?? "Unknown Equipment",
                description: equipmentCD.desc ?? "",
                rarity: Int(equipmentCD.rarity),
                buff: buff,
                slot: slot
            )
        }
    }
    
    // MARK: - Batch Operations
    
    /// Save multiple equipment items to Core Data
    func saveEquipments(_ equipments: [Equipment], ownerId: UUID? = nil) {
        for equipment in equipments {
            _ = saveEquipment(equipment, ownerId: ownerId)
        }
    }
    
    /// Load multiple equipment items from Core Data
    func loadEquipments(from equipmentCDs: [EquipmentCD]) -> [Equipment] {
        return equipmentCDs.map { loadEquipment(from: $0) }
    }
    
    /// Find all equipment owned by a player
    func findEquipmentsOwnedBy(playerId: UUID) -> [Equipment] {
        let predicate = NSPredicate(format: "ownerId == %@", playerId as CVarArg)
        let equipmentCDs = DataManager.shared.fetch(EquipmentCD.self, predicate: predicate, context: context)
        return loadEquipments(from: equipmentCDs)
    }
    
    /// Delete equipment from Core Data
    func deleteEquipment(_ equipmentId: UUID) -> Bool {
        let predicate = NSPredicate(format: "id == %@", equipmentId as CVarArg)
        if let equipmentCD = DataManager.shared.fetchOne(EquipmentCD.self, predicate: predicate, context: context) {
            DataManager.shared.delete(equipmentCD, context: context)
            return true
        }
        return false
    }
    
    // MARK: - Helper Methods
    
    /// Convert EquipmentSlot enum to string
    private func nonConsumableSlotToString(_ slot: EquipmentSlot) -> String? {
        switch slot {
        case .weapon: return "weapon"
        case .armor: return "armor"
        case .accessory: return "accessory"
        case .custom: return "custom"
        }
    }
    
    /// Convert string to EquipmentSlot enum
    private func stringToNonConsumableSlot(_ string: String) -> EquipmentSlot {
        switch string.lowercased() {
        case "weapon": return .weapon
        case "armor": return .armor
        case "accessory": return .accessory
        case "custom": return .custom
        default: return .weapon
        }
    }
}
