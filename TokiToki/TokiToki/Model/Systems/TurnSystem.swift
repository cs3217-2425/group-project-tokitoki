//
//  TurnSystem.swift
//  TokiToki
//
//  Created by proglab on 25/3/25.
//

class TurnSystem: System {
    var priority: Int = 0
    let MAX_ACTION_BAR: Float = 100
    let multiplierForActionMeter : Float = 0.1

    func update(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else { continue }
        
            statsComponent.actionMeter += multiplierForActionMeter * Float(statsComponent.speed)
            statsComponent.actionMeter = min(statsComponent.actionMeter, MAX_ACTION_BAR)
        }
    }

    func getNextEntityToAct(_ entities: [GameStateEntity]) -> GameStateEntity? {
        return entities
            .filter { $0.getActionBar() >= 100 }  
            .sorted {
                if $0.getActionBar() == $1.getActionBar() {
                    return $0.getSpeed() > $1.getSpeed()
                }
                return $0.getActionBar() > $1.getActionBar()
            }
            .first
    }

    func endTurn(for entity: GameStateEntity) {
        guard let statsComponent = entity.getComponent(ofType: StatsComponent.self) else {
            return
        }
        statsComponent.actionMeter -= MAX_ACTION_BAR
    }
}
