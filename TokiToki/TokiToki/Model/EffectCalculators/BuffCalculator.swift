//
//  BuffCalculator.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class BuffCalculator: EffectCalculator {
    func calculate(skill: Skill, source: Entity, target: Entity) -> EffectResult {
        let buffAmount = skill.basePower

        // Apply buff based on the status effect type
        if let statusEffectType = skill.statusEffect,
           let statusComponent = target.getComponent(ofType: StatusEffectsComponent.self) {

            let effect = StatusEffect(
                type: statusEffectType,
                remainingDuration: skill.statusEffectDuration,
                strength: Double(buffAmount) / 100.0,
                sourceId: source.id
            )

            statusComponent.addEffect(effect)

            let statName = getStatNameFromEffect(statusEffectType)
            return EffectResult(
                entity: target,
                type: .buff,
                value: buffAmount,
                description: "\(source.getName()) used \(skill.name) to boost \(target.getName())'s \(statName)"
            )
        }

        return EffectResult(
            entity: target,
            type: .none,
            value: 0,
            description: "\(source.getName()) used \(skill.name) but it had no effect"
        )
    }

    private func getStatNameFromEffect(_ effectType: StatusEffectType) -> String {
        let effectToStatMap: [StatusEffectType: String] = [
            .attackBuff: "attack",
            .defenseBuff: "defense",
            .speedBuff: "speed",
            .attackDebuff: "attack",
            .defenseDebuff: "defense",
            .speedDebuff: "speed"
        ]

        return effectToStatMap[effectType] ?? "stats"
    }
}
