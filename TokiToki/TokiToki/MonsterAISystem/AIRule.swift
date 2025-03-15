//
//  AIRule.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

protocol AIRule {
    var priority: Int { get }
    var action: Action { get }
    func condition(_ gameState: GameState) -> Bool
}
