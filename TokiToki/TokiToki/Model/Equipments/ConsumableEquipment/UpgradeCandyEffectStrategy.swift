//
//  Untitled.swift
//  TokiToki
//
//  Created by proglab on 11/4/25.
//

struct UpgradeCandyEffectStrategy: ConsumableEffectStrategy {
    let bonusExp: Int

    func applyEffect(name: String, to toki: Toki?, orTo entity: GameStateEntity?,
                     _ context: EffectCalculationContext,
                     completion: (() -> Void)? = nil)
    -> [EffectResult]? {
        print("Applying Upgrade Candy: +\(bonusExp) EXP permanently")
        toki?.gainExperience(bonusExp)
        completion?()
        return nil
    }
}
