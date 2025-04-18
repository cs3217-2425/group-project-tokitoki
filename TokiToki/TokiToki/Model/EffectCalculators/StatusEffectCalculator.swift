//
//  StatusEffectCalculator.swift
//  TokiToki
//
//  Created by proglab on 2/4/25.
//

class StatusEffectCalculator: EffectCalculator {
    let type: EffectCalculatorType = .statusEffect
    let statusEffectChance: Double
    let statusEffect: StatusEffectType?
    let statusEffectDuration: Int
    let statusEffectStrength: Double

    init(statusEffectChance: Double = 0, statusEffect: StatusEffectType? = nil,
         statusEffectDuration: Int = 0,
         statusEffectStrength: Double = 1.0) {
        self.statusEffectChance = statusEffectChance
        self.statusEffect = statusEffect
        self.statusEffectDuration = statusEffectDuration
        self.statusEffectStrength = statusEffectStrength
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EffectCalculatorCodingKeys.self)
        statusEffectChance = try container.decode(Double.self, forKey: .statusEffectChance)
        statusEffect = try container.decodeIfPresent(StatusEffectType.self, forKey: .statusEffect)
        statusEffectDuration = try container.decode(Int.self, forKey: .statusEffectDuration)
        statusEffectStrength = try container.decode(Double.self, forKey: .statusEffectStrength)
    }

    func encodeAdditionalProperties(to container: inout KeyedEncodingContainer<EffectCalculatorCodingKeys>) throws {
        try container.encode(statusEffectChance, forKey: .statusEffectChance)
        try container.encodeIfPresent(statusEffect, forKey: .statusEffect)
        try container.encode(statusEffectDuration, forKey: .statusEffectDuration)
        try container.encode(statusEffectStrength, forKey: .statusEffectStrength)
    }

    func calculate(moveName: String, source: GameStateEntity, target: GameStateEntity,
                   context: EffectCalculationContext) -> EffectResult? {
        guard let effectType = statusEffect else {
            return EffectResult(entity: target, value: 0,
                                description: "No status effect found!")
        }

        if Double.random(in: 0...1) > statusEffectChance {
            return nil
        }

        let effect = StatusEffect(type: effectType, remainingDuration: statusEffectDuration,
                                  strength: statusEffectStrength,
                                  sourceId: source.id, targetId: target.id)

        guard let statusComponent = target.getComponent(ofType: StatusEffectsComponent.self) else {
            return EffectResult(entity: target, value: 0,
                                description: "No status component found!")
        }

        context.globalStatusEffectsManager?.addStatusEffect(effect, target)
        return EffectResult(entity: target, value: 0,
                                    description: "\(target.name) is affected by \(effectType)!")
    }
    
    func merge(_ effectCalculator: EffectCalculator) -> EffectCalculator {
        return self
    }
}
