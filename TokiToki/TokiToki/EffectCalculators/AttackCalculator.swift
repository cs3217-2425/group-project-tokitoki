//
//  AttackCalculator.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class AttackCalculator: EffectCalculator {
    private let elementEffectivenessSystem = ElementEffectivenessSystem()

    func calculate(skill: Skill, source: Entity, target: Entity) -> EffectResult {
        guard let sourceStats = source.getComponent(ofType: StatsComponent.self),
              let targetStats = target.getComponent(ofType: StatsComponent.self) else {
            return EffectResult(entity: target, type: .none, value: 0, description: "Failed to get stats")
        }

        // Base formula
        var damage = (sourceStats.attack * skill.basePower / 100) - (targetStats.defense / 4)

        // Element effectiveness
        let elementMultiplier = elementEffectivenessSystem.getEffectiveness(of: sourceStats.elementType, against: targetStats.elementType)
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
        target.takeDamage(amount: damage)

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

        return EffectResult(entity: target, type: .damage, value: damage, description: description)
    }
}
