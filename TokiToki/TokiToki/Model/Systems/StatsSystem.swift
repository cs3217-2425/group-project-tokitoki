//
//  ActionMeterSystem.swift
//  TokiToki
//
//  Created by proglab on 25/3/25.
//

class StatsSystem {
    func modifyAttack(by amount: Int, on entities: [GameStateEntity]) {
        entities.forEach { modifyAttack(for: $0, by: amount) }
    }

    private func modifyAttack(for entity: GameStateEntity, by amount: Int) {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else { return }
        statsComponent.attack = max(1, statsComponent.attack + amount)
    }

    func modifyDefense(by amount: Int, on entities: [GameStateEntity]) {
        entities.forEach { modifyDefense(for: $0, by: amount) }
    }
    
    private func modifyDefense(for entity: GameStateEntity, by amount: Int) {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else { return }
        statsComponent.defense = max(1, statsComponent.defense + amount)
    }

    func modifySpeed(by amount: Int, on entities: [GameStateEntity]) {
        entities.forEach { modifySpeed(for: $0, by: amount) }
    }
    
    private func modifySpeed(for entity: GameStateEntity, by amount: Int) {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else { return }
        statsComponent.speed = max(1, statsComponent.speed + amount)
    }
    
    func inflictDamage(amount: Int, _ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
                return
            }
            statsComponent.currentHealth = max(0, statsComponent.currentHealth - amount)
        }
    }
    
    func heal(amount: Int, _ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
                return
            }
            statsComponent.currentHealth = min(statsComponent.maxHealth, statsComponent.currentHealth + amount)
            
        }
    }
}
