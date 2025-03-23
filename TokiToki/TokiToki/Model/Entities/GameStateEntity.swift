//
//  BaseEntity.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Base Entity Implementation
class GameStateEntity: BaseEntity {
    let MAX_ACTION_BAR: Float = 100

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

    func modifyAttack(by amount: Int) {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return
        }

        statsComponent.attack = max(1, statsComponent.attack + amount)
    }

    func modifyDefense(by amount: Int) {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return
        }

        statsComponent.defense = max(1, statsComponent.defense + amount)
    }

    func modifySpeed(by amount: Int) {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return
        }

        statsComponent.speed = max(1, statsComponent.speed + amount)
    }

    func isDead() -> Bool {
        getCurrentHealth() <= 0
    }

    func incrementActionBar(by multiplier: Float) {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return
        }

//        if statsComponent.actionMeter >= 100 {
//            statsComponent.actionMeter -= 100
//        }
        statsComponent.actionMeter += multiplier * Float(statsComponent.speed)
        statsComponent.actionMeter = min(statsComponent.actionMeter, MAX_ACTION_BAR)
    }

    func getActionBar() -> Float {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.actionMeter
    }

    func resetActionBar() {
        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
            return
        }
        statsComponent.actionMeter -= MAX_ACTION_BAR
    }
}

// struct ActionBarResult {
//    var actionMeter: Float
//    var speed: Int
// }
