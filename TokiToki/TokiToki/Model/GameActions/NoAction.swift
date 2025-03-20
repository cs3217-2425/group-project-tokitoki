//
//  NoAction.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class NoAction: Action {
    func execute(gameState: GameState) -> [EffectResult] {
        [EffectResult(entity: BaseEntity(), type: .none, value: 0, description: "No action taken")]
    }
}
