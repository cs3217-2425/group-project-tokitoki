//
//  BaseEntity.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Base Entity Implementation
class BaseEntity: Entity {
    let id = UUID()
    var components: [String: Component] = [:]

    func addComponent(_ component: Component) {
        let componentName = String(describing: type(of: component))
        components[componentName] = component
    }

    func getComponent<T: Component>(ofType type: T.Type) -> T? {
        let componentName = String(describing: type)
        return components[componentName] as? T
    }

    func removeComponent<T: Component>(ofType type: T.Type) {
        let componentName = String(describing: type)
        components.removeValue(forKey: componentName)
    }

    func getName() -> String {
        "Unknown Entity"
    }

    func getCurrentHealth() -> Int {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.currentHealth
    }

    func getMaxHealth() -> Int {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.maxHealth
    }

    func takeDamage(amount: Int) {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return
        }
        statsComponent.currentHealth = max(0, statsComponent.currentHealth - amount)
    }

    func heal(amount: Int) {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return
        }
        statsComponent.currentHealth = min(statsComponent.maxHealth, statsComponent.currentHealth + amount)
    }

    func getAttack() -> Int {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.attack
    }

    func getDefense() -> Int {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.defense
    }

    func getSpeed() -> Int {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.speed
    }
}
