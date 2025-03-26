//
//  BaseEntity.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Base Entity Implementation
class GameStateEntity: BaseEntity {
    var name: String

    init(_ name: String) {
        self.name = name
        super.init()
    }

//    func copy() -> GameStateEntity {
//        GameStateEntity(name)
//    }

    func getName() -> String {
        name
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

    func isDead() -> Bool {
        getCurrentHealth() <= 0
    }

    func getActionBar() -> Float {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.actionMeter
    }
}
