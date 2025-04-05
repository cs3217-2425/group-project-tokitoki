//
//  TurnSystem.swift
//  TokiToki
//
//  Created by proglab on 25/3/25.
//

class TurnSystem: System {
    static let shared = TurnSystem()
    var priority: Int = 0
    let MAX_ACTION_BAR: Float = GameEngine.MAX_ACTION_BAR
    var multiplierForActionMeter: Float = GameEngine.multiplierForActionMeter
    let statsSystem = StatsSystem()
    var globalTurnCounter: Int = 0 
    
    private init() {}

    func update(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else { continue }

            statsComponent.actionMeter += multiplierForActionMeter * Float(statsSystem.getSpeed(entity))
            statsComponent.actionMeter = min(statsComponent.actionMeter, MAX_ACTION_BAR)
        }
    }

    func getNextEntityToAct(_ entities: [GameStateEntity]) -> GameStateEntity? {
        let readyEntity = entities
            .filter { statsSystem.getActionBar($0) >= 100 &&
                statsSystem.checkIsEntityDead($0) == false }
            .sorted {
                if statsSystem.getActionBar($0) == statsSystem.getActionBar($1) {
                    return statsSystem.getSpeed($0) > statsSystem.getSpeed($1)
                }
                return statsSystem.getActionBar($0) > statsSystem.getActionBar($1)
            }
            .first
        if readyEntity != nil {
            globalTurnCounter += 1
        }
        return readyEntity
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
