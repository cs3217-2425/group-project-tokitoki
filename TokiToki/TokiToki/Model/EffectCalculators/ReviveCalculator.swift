//
//  ReviveCalculator.swift
//  TokiToki
//
//  Created by proglab on 15/4/25.
//

class ReviveCalculator: EffectCalculator {
    let type: EffectCalculatorType = .revive
    private let statsSystem = StatsSystem()
    private let revivePower: Float

    init(revivePower: Float) {
        self.revivePower = revivePower
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EffectCalculatorCodingKeys.self)
        revivePower = try container.decode(Float.self, forKey: .revivePower)
    }

    func encodeAdditionalProperties(to container: inout KeyedEncodingContainer<EffectCalculatorCodingKeys>) throws {
        try container.encode(revivePower, forKey: .revivePower)
    }

    func calculate(moveName: String, source: GameStateEntity, target: GameStateEntity,
                   context: EffectCalculationContext) -> EffectResult? {
        
        if statsSystem.getCurrentHealth(target) > 0 {
            return EffectResult(entity: target, value: 0,
                                description: "\(source.getName()) used \(moveName) "
                                + "but there's no effect!")
        }
    
        statsSystem.revive(amount: revivePower, [target])
        context.battleEffectsDelegate?.showRevive(target.id)
        context.battleEffectsDelegate?.updateHealthBar(target.id, statsSystem.getCurrentHealth(target),
                                                       statsSystem.getMaxHealth(target), completion: {})
        context.reviverDelegate?.handleRevive(target)
        
        let percentageString = String(format: "%.0f%%", revivePower * 100)
        let healthRestored = Int(revivePower * Float(statsSystem.getMaxHealth(source)))
        return EffectResult(entity: target, value: healthRestored,
                            description: "\(source.getName()) used \(moveName) "
                            + "to revive \(target.getName()) and regain \(percentageString) HP")
    }
    
    func merge(_ effectCalculator: EffectCalculator) -> EffectCalculator {
        guard let reviveCalculator = effectCalculator as? ReviveCalculator else {
            return self
        }
        return ReviveCalculator(revivePower: self.revivePower + reviveCalculator.revivePower)
    }
}
