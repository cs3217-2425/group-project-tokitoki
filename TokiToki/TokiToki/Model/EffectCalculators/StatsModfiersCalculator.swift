//
//  StatsModfiersCalculator.swift
//  TokiToki
//
//  Created by proglab on 2/4/25.
//

class StatsModifiersCalculator: EffectCalculator {
    private let statsSystem = StatsSystem()
    let statsModifiers: [StatsModifier]
    
    init(statsModifiers: [StatsModifier] = []) {
        self.statsModifiers = statsModifiers
    }

    func calculate(skill: Skill, source: GameStateEntity, target: GameStateEntity) -> EffectResult? {
        for modifier in statsModifiers {
            guard let statsModifiersComponent = target.getComponent(ofType: StatsModifiersComponent.self) else {
                return nil
            }
            StatsModifiersSystem().addModifier(modifier, target)
            return EffectResult(entity: target, type: .statsModified, value: 0,
                                        description: modifier.describeChanges(for: target))
        }
        return nil
    }
}
