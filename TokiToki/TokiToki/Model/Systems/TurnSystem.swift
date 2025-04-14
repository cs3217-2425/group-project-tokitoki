//
//  TurnSystem.swift
//  TokiToki
//
//  Created by proglab on 25/3/25.
//

class TurnSystem: System {
    let MAX_ACTION_BAR: Float
    let MULTIPLIER_FOR_ACTION_METER: Float
    let statsSystem: StatsSystem
    
    init(_ statsSystem: StatsSystem, _ max_action_bar: Float, _ multiplier_for_action_meter: Float) {
        self.statsSystem = statsSystem
        self.MAX_ACTION_BAR = max_action_bar
        self.MULTIPLIER_FOR_ACTION_METER = multiplier_for_action_meter
    }

    func update(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else { continue }

            statsComponent.actionMeter += MULTIPLIER_FOR_ACTION_METER * Float(statsSystem.getSpeed(entity))
            statsComponent.actionMeter = min(statsComponent.actionMeter, MAX_ACTION_BAR)
        }
    }

    func getNextEntityToAct(_ entities: [GameStateEntity]) -> GameStateEntity? {
        let readyEntity = entities
            .filter { statsSystem.getActionBar($0) >= 100 &&
                statsSystem.checkIsEntityDead($0) == false
            }
            .sorted {
                if statsSystem.getActionBar($0) == statsSystem.getActionBar($1) {
                    return statsSystem.getSpeed($0) > statsSystem.getSpeed($1)
                }
                return statsSystem.getActionBar($0) > statsSystem.getActionBar($1)
            }
            .first

        return readyEntity
    }

    func endTurn(for entity: GameStateEntity) {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
            return
        }
        statsComponent.actionMeter -= MAX_ACTION_BAR
    }

    func reset(_ entities: [GameStateEntity]) {
        // Does nothing
    }
}
