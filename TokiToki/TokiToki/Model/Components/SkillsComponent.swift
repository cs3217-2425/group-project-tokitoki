//
//  SkillsComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class SkillsComponent: Component {
    var skills: [Skill]
    let entity: Entity

    init(entity: Entity, skills: [Skill]) {
        self.skills = skills
        self.entity = entity
    }
}
