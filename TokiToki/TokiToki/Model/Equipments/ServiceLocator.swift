//
//  ServiceLocator.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

class ServiceLocator {
    static let shared = ServiceLocator()
    private init() {}

    lazy var equipmentSystem = EquipmentSystem()
    lazy var craftingManager: CraftingManager = {
        let manager = CraftingManager(recipes: [])
        return manager
    }()
    lazy var equipmentLogger: EquipmentLogger = DefaultEquipmentLogger.shared
    lazy var dataStore: EquipmentDataStore = InMemoryEquipmentDataStore.shared
}
