//
//  EquipmentDataStore.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//


import Foundation

protocol EquipmentDataStore {
    var equipmentComponent: EquipmentComponent { get set }
    func save() // Simulate persistence
    func load() -> EquipmentComponent
}

class InMemoryEquipmentDataStore: EquipmentDataStore {
    static let shared = InMemoryEquipmentDataStore()
    
    private init() {
        self.equipmentComponent = EquipmentComponent()
    }
    
    // TODO: equipment component needs to be attached to an entity
    var equipmentComponent: EquipmentComponent
    
    func save() {
        DefaultEquipmentLogger.shared.log("EquipmentDataStore saved equipment state.")
    }
    
    func load() -> EquipmentComponent {
        DefaultEquipmentLogger.shared.log("EquipmentDataStore loaded equipment state.")
        return equipmentComponent
    }
}
