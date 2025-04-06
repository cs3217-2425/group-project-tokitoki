import CoreData
import Foundation

class CoreDataEquipmentRepository {
    private let context: NSManagedObjectContext
    
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
            
            // Handle specific consumable types
            if let potion = equipment as? Potion {
                equipmentCD.effect_type = "potion"
                // Store any specific potion properties
                // Note: We can't save the full effectCalculators array, but we can save metadata
                equipmentCD.consumable_usage_context = consumableUsageContextToString(potion.usageContext)
            } else if let candy = equipment as? Candy {
                equipmentCD.effect_type = "candy"
                equipmentCD.effect_bonusExp = Int32(candy.bonusExp)
                equipmentCD.consumable_usage_context = consumableUsageContextToString(candy.usageContext)
            } else {
                // Generic consumable
                equipmentCD.effect_type = "generic"
                if let consumable = equipment as? ConsumableEquipment {
                    equipmentCD.consumable_usage_context = consumableUsageContextToString(consumable.usageContext)
                }
            }
            
        case .nonConsumable:
            equipmentCD.equipmentType = "nonConsumable"
            
            if let nonConsumable = equipment as? NonConsumableEquipment {
                equipmentCD.buff_value = Int32(nonConsumable.buff.value)
                equipmentCD.buff_desc = nonConsumable.buff.description
                equipmentCD.buff_affectedStat = nonConsumable.buff.affectedStat
                
                // Store slot information
                equipmentCD.equipment_slot = nonConsumableSlotToString(nonConsumable.slot)
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
            let effectTypeString = equipmentCD.effect_type ?? "generic"
            let usageContext = stringToConsumableUsageContext(equipmentCD.consumable_usage_context ?? "battleOnly")
            
            switch effectTypeString {
            case "potion":
                // Create a simple effect calculator for the potion
                let healCalculator = StatsModifiersCalculator(statsModifiers: [
                    StatsModifier(
                        remainingDuration: 1,
                        attack: 0,
                        defense: 0,
                        speed: 0,
                        heal: Double(equipmentCD.effect_buffValue)
                    )
                ])
                
                return Potion(
                    name: equipmentCD.name ?? "Unknown Potion",
                    description: equipmentCD.desc ?? "A mysterious potion",
                    rarity: Int(equipmentCD.rarity),
                    effectCalculators: [healCalculator]
                )
                
            case "candy":
                return Candy(
                    name: equipmentCD.name ?? "Unknown Candy",
                    description: equipmentCD.desc ?? "A mysterious candy",
                    rarity: Int(equipmentCD.rarity),
                    bonusExp: Int(equipmentCD.effect_bonusExp)
                )
                
            default:
                // Create a generic potion as fallback
                return Potion(
                    name: equipmentCD.name ?? "Unknown Consumable",
                    description: equipmentCD.desc ?? "A mysterious item",
                    rarity: Int(equipmentCD.rarity),
                    effectCalculators: []
                )
            }
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
            let slot = stringToNonConsumableSlot(equipmentCD.equipment_slot ?? "weapon")
            
            return NonConsumableEquipment(
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
    private func nonConsumableSlotToString(_ slot: EquipmentSlot) -> String {
        return slot.rawValue
    }
    
    /// Convert string to EquipmentSlot enum
    private func stringToNonConsumableSlot(_ string: String) -> EquipmentSlot {
        return EquipmentSlot(rawValue: string.lowercased()) ?? .weapon
    }
    
    /// Convert ConsumableUsageContext enum to string
    private func consumableUsageContextToString(_ context: ConsumableUsageContext) -> String {
        switch context {
        case .battleOnly: return "battleOnly"
        case .outOfBattleOnly: return "outOfBattleOnly"
        case .anywhere: return "anywhere"
        }
    }
    
    /// Convert string to ConsumableUsageContext enum
    private func stringToConsumableUsageContext(_ string: String) -> ConsumableUsageContext {
        switch string.lowercased() {
        case "battleonly": return .battleOnly
        case "outofbattleonly": return .outOfBattleOnly
        case "anywhere": return .anywhere
        default: return .battleOnly
        }
    }
}
