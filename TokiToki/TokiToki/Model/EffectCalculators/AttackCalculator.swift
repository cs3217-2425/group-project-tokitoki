//
//  AttackCalculator.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class AttackCalculator: EffectCalculator {
    private let elementsSystem: ElementsSystem
    private let statsSystem = StatsSystem()

    init(elementsSystem: ElementsSystem) {
        self.elementsSystem = elementsSystem
    }

    func calculate(skill: Skill, source: GameStateEntity, target: GameStateEntity) -> EffectResult {
        guard let sourceStats = source.getComponent(ofType: StatsComponent.self),
              let targetStats = target.getComponent(ofType: StatsComponent.self) else {
            return EffectResult(entity: target, type: .none, value: 0, description: "Failed to get stats")
        }

        // Base formula
        var damage = (sourceStats.attack * skill.basePower / 100) - (targetStats.defense / 4)

        // Element effectiveness
        let elementMultiplier = elementsSystem.getEffectiveness(of: sourceStats.elementType,
                                                                against: [targetStats.elementType])
        damage = Int(Double(damage) * elementMultiplier)

        // Critical hit (10% chance)
        var isCritical = false
        if Double.random(in: 0...1) < 0.1 {
            damage = Int(Double(damage) * 1.5)
            isCritical = true
        }

        // Ensure minimum damage
        damage = max(1, damage)

        // Apply damage
        statsSystem.inflictDamage(amount: damage, [target])

        // Create result
        var description = "\(source.getName()) used \(skill.name) on \(target.getName()) for \(damage) damage"

        if elementMultiplier > 1.0 {
            description += " (super effective!)"
        } else if elementMultiplier < 1.0 {
            description += " (not very effective...)"
        }

        if isCritical {
            description += " (critical hit!)"
        }

        return DamageEffectResult(
            entity: target,
            value: damage,
            description: description,
            isCritical: isCritical,
            elementType: sourceStats.elementType
        )
    }
}
