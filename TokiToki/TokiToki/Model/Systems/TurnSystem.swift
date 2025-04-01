//
//  TurnSystem.swift
//  TokiToki
//
//  Created by proglab on 25/3/25.
//

class TurnSystem: System {
    var priority: Int = 0
    let MAX_ACTION_BAR: Float = 100
    let multiplierForActionMeter: Float = 0.1
    let statsSystem = StatsSystem()
    var globalTurnCounter: Int = 0 // TODO: Update counter

    func update(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else { continue }

            statsComponent.actionMeter += multiplierForActionMeter * Float(statsComponent.baseStats.speed)
            statsComponent.actionMeter = min(statsComponent.actionMeter, MAX_ACTION_BAR)
        }
    }

    func getNextEntityToAct(_ entities: [GameStateEntity]) -> GameStateEntity? {
        entities
            .filter { statsSystem.getActionBar($0) >= 100 }
            .sorted {
                if statsSystem.getActionBar($0) == statsSystem.getActionBar($1) {
                    return statsSystem.getSpeed($0) > statsSystem.getSpeed($1)
                }
                return statsSystem.getActionBar($0) > statsSystem.getActionBar($1)
            }
            .first
    }

    func endTurn(for entity: GameStateEntity) {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
            return
        }
        statsComponent.actionMeter -= MAX_ACTION_BAR
    }
    
    func reset(_ entities: [GameStateEntity]) {
        globalTurnCounter = 0
    }
}
