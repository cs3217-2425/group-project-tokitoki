//
//  SkillsSystem.swift
//  TokiToki
//
//  Created by proglab on 25/3/25.
//

class SkillsSystem: System {
    func update(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let skillsComponent = entity.getComponent(ofType: SkillsComponent.self) else { continue }

            for skill in skillsComponent.skills {
                skill.reduceCooldown()
            }
        }
    }

    func reset(_ entities: [GameStateEntity]) {
        for entity in entities {
            guard let skillsComponent = entity.getComponent(ofType: SkillsComponent.self) else { continue }

            for skill in skillsComponent.skills {
                skill.resetCooldown()
            }
        }
    }
}
