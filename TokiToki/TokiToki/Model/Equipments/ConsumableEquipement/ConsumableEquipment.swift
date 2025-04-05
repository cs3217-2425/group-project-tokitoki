//
//  ConsumableEquipment.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

protocol ConsumableEquipment: Equipment {
    func applyEffect(to toki: Toki?,
                     _ entity: GameStateEntity?, completion: (() -> Void)?) -> [EffectResult]?
}
