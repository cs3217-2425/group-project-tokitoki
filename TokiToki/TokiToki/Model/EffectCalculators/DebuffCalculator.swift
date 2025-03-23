//
//  DebuffCalculator.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class DebuffCalculator: EffectCalculator {
    func calculate(skill: Skill, source: GameStateEntity, target: GameStateEntity) -> EffectResult {
        let debuffAmount = skill.basePower

        // Apply debuff based on the status effect type
        if let statusEffectType = skill.statusEffect,
           let statusComponent = target.getComponent(ofType: StatusEffectsComponent.self) {

            let effect = StatusEffect(
                type: statusEffectType,
                remainingDuration: skill.statusEffectDuration,
                strength: Double(debuffAmount) / 100.0,
                sourceId: source.id
            )

            statusComponent.addEffect(effect)

            let statName = getStatNameFromEffect(statusEffectType)
            return EffectResult(
                entity: target,
                type: .debuff,
                value: debuffAmount,
                description: "\(source.getName()) used \(skill.name) to lower \(target.getName())'s \(statName)"
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
