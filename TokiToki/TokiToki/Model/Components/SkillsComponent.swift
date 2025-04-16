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
        let clonedSkills = skills.map { $0.clone() }
        self.skills = clonedSkills
        self.entity = entity
    }
}
