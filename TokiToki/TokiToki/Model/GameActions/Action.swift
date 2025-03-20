//
//  Action.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

// Action Protocol - Command Pattern
protocol Action {
    func execute(gameState: GameState) -> [EffectResult]
}
