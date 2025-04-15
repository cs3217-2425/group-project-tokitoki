//
//  ActionMeterSystem.swift
//  TokiToki
//
//  Created by proglab on 25/3/25.
//

class StatsSystem: System {
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
            statsComponent.currentHealth = min(statsComponent.baseStats.hp, statsComponent.currentHealth + amount)

        }
    }
    
    func revive(amount: Float, _ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
                return
            }
            let healthToRestore = Float(getMaxHealth(entity)) * amount
            statsComponent.currentHealth = min(statsComponent.baseStats.hp, Int(healthToRestore))
        }
    }

    func update(_ entities: [GameStateEntity]) {
        // does nothing
    }

    func reset(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
                return
            }
            statsComponent.currentHealth = statsComponent.baseStats.hp
            statsComponent.actionMeter = 0
        }
    }

    private func getStatValue(for keyPath: KeyPath<TokiBaseStats, Int>,
                              modifierKeyPath: KeyPath<StatsModifier, Double>,
                              _ entity: GameStateEntity) -> Int {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self),
              let statsModifiersComponent = entity.getComponent(ofType: StatsModifiersComponent.self) else {
            return 0
        }
        let modifiedStat: Double = statsModifiersComponent.statsModifiers
            .reduce(Double(statsComponent.baseStats[keyPath: keyPath])) { Double($0) * $1[keyPath: modifierKeyPath] }
        return Int(modifiedStat)
    }

    func getAttack(_ entity: GameStateEntity) -> Int {
        getStatValue(for: \.attack, modifierKeyPath: \.attack, entity)
    }

    func getDefense(_ entity: GameStateEntity) -> Int {
        getStatValue(for: \.defense, modifierKeyPath: \.defense, entity)
    }

    func getSpeed(_ entity: GameStateEntity) -> Int {
        getStatValue(for: \.speed, modifierKeyPath: \.speed, entity)
    }

    func getHeal(_ entity: GameStateEntity) -> Int {
        getStatValue(for: \.heal, modifierKeyPath: \.heal, entity)
    }

    func getCritChance(_ entity: GameStateEntity) -> Int {
        getStatValue(for: \.critHitChance, modifierKeyPath: \.criticalHitChance, entity)
    }

    func getCritDmg(_ entity: GameStateEntity) -> Int {
        getStatValue(for: \.critHitDamage, modifierKeyPath: \.criticalHitDmg, entity)
    }

    func getCurrentHealth(_ entity: GameStateEntity) -> Int {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.currentHealth
    }

    func getMaxHealth(_ entity: GameStateEntity) -> Int {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.baseStats.hp
    }

    func checkIsEntityDead(_ entity: GameStateEntity) -> Bool {
        getCurrentHealth(entity) <= 0
    }

    func getActionBar(_ entity: GameStateEntity) -> Float {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
            return 0
        }
        return statsComponent.actionMeter
    }
}
