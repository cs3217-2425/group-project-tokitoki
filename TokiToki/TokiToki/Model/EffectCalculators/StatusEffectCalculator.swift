//
//  StatusEffectCalculator.swift
//  TokiToki
//
//  Created by proglab on 2/4/25.
//

class StatusEffectCalculator: EffectCalculator {
    private let statsSystem = StatsSystem()
    private let statusEffectsSystem = StatusEffectsSystem.shared
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

    func calculate(moveName: String, source: GameStateEntity, target: GameStateEntity) -> EffectResult? {
        guard let effectType = statusEffect else {
            return EffectResult(entity: target, type: .statusApplied, value: 0,
                                description: "No status effect found!")
        }
        
        if Double.random(in: 0...1) > statusEffectChance {
            return nil
        }
        
        let effect = StatusEffect(type: effectType, remainingDuration: statusEffectDuration,
                                  strength: statusEffectStrength,
                                  sourceId: source.id, target: target)
        
        guard let statusComponent = target.getComponent(ofType: StatusEffectsComponent.self) else {
            return EffectResult(entity: target, type: .statusApplied, value: 0,
                                description: "No status component found!")
        }
        
        statusEffectsSystem.addEffect(effect, target)
        return EffectResult(entity: target, type: .statusApplied, value: 0,
                                    description: "\(target.name) is affected by \(effectType)!")
    }
}
