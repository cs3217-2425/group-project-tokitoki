//
//  SkillsComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class SkillsComponent: BaseComponent {
    var skills: [Skill]

    init(entityId: UUID, skills: [Skill]) {
        self.skills = skills
        super.init(entityId: entityId)
    }
}
