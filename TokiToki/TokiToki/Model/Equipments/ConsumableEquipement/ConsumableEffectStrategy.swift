//
//  ConsumableEffectStrategy.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

 import Foundation

 protocol ConsumableEffectStrategy {
    // Takes in both toki and game state entity as arguments because a consumable
    // can either be used on a toki outside of battle, or on a game state entity during battle
    func applyEffect(to toki: Toki?,
                     _ entity: GameStateEntity?, completion: (() -> Void)?) -> [EffectResult]?
 }

 struct PotionEffectStrategy: ConsumableEffectStrategy {
    let effectCalculators: [EffectCalculator]

     func applyEffect(to toki: Toki?, _ entity: GameStateEntity?, completion: (() -> Void)? = nil)
     -> [EffectResult]? {
         guard let entity = entity else {
             return nil
         }
         var results: [EffectResult] = []
         for effectCalculator in effectCalculators {
             let result = effectCalculator.calculate(moveName: name,
                                                     source: entity, target: entity)
             guard let result = result else {
                 continue
             }
             results.append(result)
         }
         completion?()
         return results
    }
 }

 struct UpgradeCandyEffectStrategy: ConsumableEffectStrategy {
    let bonusExp: Int

    func applyEffect(to toki: Toki?,
                     _ entity: GameStateEntity?, completion: (() -> Void)? = nil)
     -> [EffectResult]? {
        print("Applying Upgrade Candy: +\(bonusExp) EXP permanently")
        toki?.gainExperience(bonusExp)
        completion?()
    }
 }
