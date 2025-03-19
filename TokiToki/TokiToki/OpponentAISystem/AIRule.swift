//
//  AIRule.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

protocol AIRule {
    var priority: Int { get }
    var skillAction: UseSkillAction { get }
    func condition(_ entity: GameStateEntity) -> Bool
}
