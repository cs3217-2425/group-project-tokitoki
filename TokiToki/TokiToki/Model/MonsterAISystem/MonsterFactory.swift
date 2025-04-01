//
//  MonsterFactory.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

//class MonsterFactory {
//    private let skillFactory = SkillFactory()
//
//    func createBasicMonster(name: String, health: Int, attack: Int, defense: Int, speed: Int,
//                            elementType: ElementType) -> GameStateEntity {
//        let monster = GameStateEntity(name)
//
//        // Create basic stats
//        let statsComponent = StatsComponent(
//            entity: monster,
//            maxHealth: health,
//            attack: attack,
//            defense: defense,
//            speed: speed,
//            elementType: elementType
//        )
//
//        // Create basic skills
//        let basicAttack = skillFactory.createAttackSkill(
//            name: "Basic Attack",
//            description: "A basic attack",
//            elementType: elementType,
//            basePower: 100,
//            cooldown: 0,
//            targetType: .singleEnemy
//        )
//
//        let skillsComponent = SkillsComponent(entity: monster, skills: [basicAttack])
//
//        // Add status effects component
//        let statusEffectsComponent = StatusEffectsComponent(entity: monster)
//
//        // Add AI component with basic rules
//        let aiRules: [AIRule] = [
//            HealthBelowPercentageRule(
//                priority: 1,
//                action: basicAttack,
//                percentage: 30
//            )
//        ]
//
//        let aiComponent = AIComponent(entity: monster, rules: aiRules, skills: [basicAttack])
//
//        // Add components to the monster
//        monster.addComponent(statsComponent)
//        monster.addComponent(skillsComponent)
//        monster.addComponent(statusEffectsComponent)
//        monster.addComponent(aiComponent)
//
//        return monster
//    }
//
//    func createBossMonster(name: String, health: Int, attack: Int, defense: Int,
//                           speed: Int, elementType: ElementType) -> GameStateEntity {
//        let boss = GameStateEntity(name)
//
//        // Create boss stats
//        let statsComponent = StatsComponent(
//            entity: boss,
//            maxHealth: health,
//            attack: attack,
//            defense: defense,
//            speed: speed,
//            elementType: elementType
//        )
//
//        // Create boss skills
//        let basicAttack = skillFactory.createAttackSkill(
//            name: "Powerful Strike",
//            description: "A powerful strike that deals damage to a single target",
//            elementType: elementType,
//            basePower: 120,
//            cooldown: 0,
//            targetType: .singleEnemy
//        )
//
//        let aoeAttack = skillFactory.createAttackSkill(
//            name: "Area Blast",
//            description: "An attack that damages all enemies",
//            elementType: elementType,
//            basePower: 80,
//            cooldown: 3,
//            targetType: .allEnemies
//        )
//
//        let skillsComponent = SkillsComponent(entity: boss, skills: [basicAttack, aoeAttack])
//
//        // Add status effects component
//        let statusEffectsComponent = StatusEffectsComponent(entity: boss)
//
//        // Add AI component with boss rules
//        let aiRules: [AIRule] = [
//            // Use AOE attack when it's available
//            HealthBelowPercentageRule(
//                priority: 1,
//                action: aoeAttack,
//                percentage: 50
//            ),
//        ]
//
//        let aiComponent = AIComponent(entity: boss, rules: aiRules, skills: [basicAttack, aoeAttack])
//
//        // Add components to the boss
//        boss.addComponent(statsComponent)
//        boss.addComponent(skillsComponent)
//        boss.addComponent(statusEffectsComponent)
//        boss.addComponent(aiComponent)
//
//        return boss
//    }
//}
