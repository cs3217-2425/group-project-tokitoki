//
//  ConsumableEffectStrategy.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

protocol ConsumableEffectStrategy {
    func applyEffect(name: String, to toki: Toki?, orTo entity: GameStateEntity?, completion: (() -> Void)?) -> [EffectResult]?
}




