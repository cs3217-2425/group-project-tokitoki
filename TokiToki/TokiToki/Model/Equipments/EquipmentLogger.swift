//
//  EquipmentLogger.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//


import Foundation

protocol EquipmentLogger {
    func log(_ message: String)
    func logEvent(_ event: EquipmentEvent)
}

enum EquipmentEvent {
    case equipped(item: Equipment)
    case consumed(item: Equipment)
    case crafted(item: Equipment)
    case equipFailed(reason: String)
    case consumeFailed(reason: String)
    case craftingFailed(reason: String)
}

class DefaultEquipmentLogger: EquipmentLogger {
    static let shared = DefaultEquipmentLogger()
    private init() {}
    
    func log(_ message: String) {
        print("[EquipmentLogger] \(message)")
    }
    
    func logEvent(_ event: EquipmentEvent) {
        switch event {
        case .equipped(let item):
            log("Equipped: \(item.name)")
        case .consumed(let item):
            log("Consumed: \(item.name)")
        case .crafted(let item):
            log("Crafted: \(item.name)")
        case .equipFailed(let reason):
            log("Equip Failed: \(reason)")
        case .consumeFailed(let reason):
            log("Consume Failed: \(reason)")
        case .craftingFailed(let reason):
            log("Crafting Failed: \(reason)")
        }
    }
}