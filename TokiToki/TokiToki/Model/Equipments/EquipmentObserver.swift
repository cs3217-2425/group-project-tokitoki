//
//  EquipmentObserver.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

protocol EquipmentObserver: AnyObject {
    func onEquipmentEvent(_ event: EquipmentEvent)
}

class EquipmentEventManager {
    static let shared = EquipmentEventManager()
    private init() {}

    private var observers = NSHashTable<AnyObject>.weakObjects()

    func addObserver(_ observer: EquipmentObserver) {
        observers.add(observer)
    }

    func removeObserver(_ observer: EquipmentObserver) {
        observers.remove(observer)
    }

    func notify(event: EquipmentEvent) {
        for observer in observers.allObjects {
            (observer as? EquipmentObserver)?.onEquipmentEvent(event)
        }
    }
}
