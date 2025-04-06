//
//  StatusEffectsComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class StatusEffectsComponent: Component {
    var activeEffects: [StatusEffect]
    let entity: Entity

    init(entity: Entity) {
        self.activeEffects = []
        self.entity = entity
    }
}
