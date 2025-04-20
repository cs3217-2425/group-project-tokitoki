//
//  AIComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// AI Component for opponents to determine which skill to use
class AIComponent: Component {
    var rules: [AIRule]
    var skills: [Skill]
    let entity: Entity

    init(entity: Entity, rules: [AIRule], skills: [Skill]) {
        self.rules = rules
        self.skills = skills
        self.entity = entity
    }
}
