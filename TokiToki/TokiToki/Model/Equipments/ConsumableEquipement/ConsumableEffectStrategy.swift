//
//  ConsumableEffectStrategy.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

//import Foundation
//
//protocol ConsumableEffectStrategy {
//    // Takes in both toki and game state entity as arguments because a consumable
//    // can either be used on a toki outside of battle, or on a game state entity during battle
//    func applyEffect(to toki: Toki?,
//                     _ entity: GameStateEntity?, completion: (() -> Void)?)
//}
//
//struct PotionEffectStrategy: ConsumableEffectStrategy {
//    let effectDefinitions: [EffectDefinition]
//
//    func applyEffect(to toki: Toki?, _ entity: GameStateEntity?, completion: (() -> Void)? = nil) {
//        for effectDefinition in effectDefinitions {
//            for effectCalculator in effectDefinition.effectCalculators {
//                let result = effectCalculator.calculate(moveName: , source: source, target: target)
//                guard let result = result else {
//                    continue
//                }
//                results.append(result)
//            }
//        }
//        completion?()
//    }
//}
//
//struct UpgradeCandyEffectStrategy: ConsumableEffectStrategy {
//    let bonusExp: Int
//
//    func applyEffect(to toki: Toki?,
//                     _ entity: GameStateEntity?, completion: (() -> Void)? = nil) {
//        print("Applying Upgrade Candy: +\(bonusExp) EXP permanently")
//        toki?.gainExperience(bonusExp)
//        completion?()
//    }
//}
