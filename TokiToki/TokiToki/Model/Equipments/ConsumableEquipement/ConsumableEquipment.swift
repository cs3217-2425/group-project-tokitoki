//
//  ConsumableEquipment.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//

import Foundation

protocol ConsumableEquipment: Equipment {
    var usageContext: ConsumableUsageContext { get }
    func applyEffect(to toki: Toki?,
                     _ entity: GameStateEntity?, completion: (() -> Void)?) -> [EffectResult]?
}
