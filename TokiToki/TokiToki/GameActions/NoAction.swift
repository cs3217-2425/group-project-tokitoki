//
//  NoAction.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class NoAction: Action {
    func execute() -> [EffectResult] {
        [EffectResult(entity: GameStateEntity("doesnt matter"), type: .none, value: 0, description: "No action taken")]
    }
}
