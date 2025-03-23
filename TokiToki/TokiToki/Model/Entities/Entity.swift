//
//  Entity.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Entity Protocol
protocol Entity {
    var id: UUID { get }
    var components: [String: Component] { get set }

    func addComponent(_ component: Component)
    func getComponent<T: Component>(ofType type: T.Type) -> T?
    func removeComponent<T: Component>(ofType type: T.Type)
    func getName() -> String
    func getCurrentHealth() -> Int
    func getMaxHealth() -> Int
    func takeDamage(amount: Int)
    func heal(amount: Int)
    func getAttack() -> Int
    func getDefense() -> Int
    func getSpeed() -> Int
}
