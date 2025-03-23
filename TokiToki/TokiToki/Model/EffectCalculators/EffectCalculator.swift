//
//  Untitled.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

protocol EffectCalculator {
    func calculate(skill: Skill, source: GameStateEntity, target: GameStateEntity) -> EffectResult
}
