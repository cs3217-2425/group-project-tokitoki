//
//  AttackCalculator.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class AttackCalculator: EffectCalculator {
    private let elementsSystem = ElementsSystem()
    private let statsSystem = StatsSystem()
    private let elementType: ElementType
    private let basePower: Int

    init(elementType: ElementType, basePower: Int) {
        self.elementType = elementType
        self.basePower = basePower
    }

    func calculate(moveName: String, source: GameStateEntity, target: GameStateEntity) -> EffectResult? {
        guard let sourceStats = source.getComponent(ofType: StatsComponent.self),
              let targetStats = target.getComponent(ofType: StatsComponent.self) else {
            return EffectResult(entity: target, value: 0, description: "Failed to get stats")
        }

        // Base formula
        var damage = (statsSystem.getAttack(source) * basePower / 100)
        - (statsSystem.getDefense(target) / 4)

        let elementMultiplier = elementsSystem.getEffectiveness(of: elementType,
                                                                against: targetStats.elementType)
        damage = Int(Double(damage) * elementMultiplier)

        var isCritical = false
        if Double.random(in: 0...1) < Double(statsSystem.getCritChance(source)) / 100 {
            damage = Int(Double(damage) * Double(statsSystem.getCritDmg(source)) / 100)
            isCritical = true
        }

        damage = max(1, damage)

        statsSystem.inflictDamage(amount: damage, [target])

        var description = "\(source.getName()) used \(moveName) on \(target.getName()) for \(damage) damage"

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
            elementType: elementType
        )
    }
}
