//
//  MonsterFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class MonsterFactory {
    private let skillFactory: SkillFactory

    init(skillFactory: SkillFactory) {
        self.skillFactory = skillFactory
    }

    func createBasicMonster(name: String, health: Int, attack: Int, defense: Int, speed: Int, elementType: ElementType) -> MonsterEntity {
        let monster = MonsterEntity(name: name)

        // Create basic stats
        let statsComponent = StatsComponent(
            entityId: monster.id,
            maxHealth: health,
            attack: attack,
            defense: defense,
            speed: speed,
            elementType: elementType
        )

        // Create basic skills
        let basicAttack = skillFactory.createAttackSkill(
            name: "Basic Attack",
            description: "A basic attack",
            elementType: elementType,
            basePower: 100,
            cooldown: 0,
            targetType: .single
        )

        let skillsComponent = SkillsComponent(entityId: monster.id, skills: [basicAttack])

        // Add status effects component
        let statusEffectsComponent = StatusEffectsComponent(entityId: monster.id)

        // Add AI component with basic rules
        let aiRules: [AIRule] = [
            HealthBelowPercentageRule(
                priority: 1,
                action: UseSkillAction(sourceId: monster.id, skillId: basicAttack.id, targetIds: []), // Target IDs will be filled at runtime
                percentage: 30
            )
        ]

        let aiComponent = AIComponent(entityId: monster.id, rules: aiRules)

        // Add components to the monster
        monster.addComponent(statsComponent)
        monster.addComponent(skillsComponent)
        monster.addComponent(statusEffectsComponent)
        monster.addComponent(aiComponent)

        return monster
    }

    func createBossMonster(name: String, health: Int, attack: Int, defense: Int, speed: Int, elementType: ElementType) -> MonsterEntity {
        let boss = MonsterEntity(name: name)

        // Create boss stats
        let statsComponent = StatsComponent(
            entityId: boss.id,
            maxHealth: health,
            attack: attack,
            defense: defense,
            speed: speed,
            elementType: elementType
        )

        // Create boss skills
        let basicAttack = skillFactory.createAttackSkill(
            name: "Powerful Strike",
            description: "A powerful strike that deals damage to a single target",
            elementType: elementType,
            basePower: 120,
            cooldown: 0,
            targetType: .single
        )

        let aoeAttack = skillFactory.createAttackSkill(
            name: "Area Blast",
            description: "An attack that damages all enemies",
            elementType: elementType,
            basePower: 80,
            cooldown: 3,
            targetType: .allEnemies
        )

        let debuffSkill = skillFactory.createDebuffSkill(
            name: "Weaken",
            description: "Weakens the target, reducing their attack",
            basePower: 50,
            cooldown: 4,
            targetType: .single,
            statusEffect: .attackDebuff,
            duration: 3
        )

        let skillsComponent = SkillsComponent(entityId: boss.id, skills: [basicAttack, aoeAttack, debuffSkill])

        // Add status effects component
        let statusEffectsComponent = StatusEffectsComponent(entityId: boss.id)

        // Add AI component with boss rules
        let aiRules: [AIRule] = [
            // Use AOE attack when it's available
            HealthBelowPercentageRule(
                priority: 1,
                action: UseSkillAction(sourceId: boss.id, skillId: aoeAttack.id, targetIds: []), // Target IDs will be filled at runtime
                percentage: 50
            ),
            // Use debuff when health is high
            HealthBelowPercentageRule(
                priority: 2,
                action: UseSkillAction(sourceId: boss.id, skillId: debuffSkill.id, targetIds: []), // Target IDs will be filled at runtime
                percentage: 80
            )
        ]

        let aiComponent = AIComponent(entityId: boss.id, rules: aiRules)

        // Add components to the boss
        boss.addComponent(statsComponent)
        boss.addComponent(skillsComponent)
        boss.addComponent(statusEffectsComponent)
        boss.addComponent(aiComponent)

        return boss
    }
}
