//
//  Entity+Modifiers.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

// extension Entity {
//    func modifyAttack(by amount: Int) {
//        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
//            return
//        }
//
//        statsComponent.attack = max(1, statsComponent.attack + amount)
//    }
//
//    func modifyDefense(by amount: Int) {
//        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
//            return
//        }
//
//        statsComponent.defense = max(1, statsComponent.defense + amount)
//    }
//
//    func modifySpeed(by amount: Int) {
//        guard let statsComponent = getComponent(ofType: StatsComponent.self) else {
//            return
//        }
//
//        statsComponent.speed = max(1, statsComponent.speed + amount)
//    }
//
//    func isDead() -> Bool {
//        getCurrentHealth() <= 0
//    }
// }
