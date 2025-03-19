//
//  EndTurnAction.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class EndTurnAction: Action {
//    let entityId: UUID
//
//    init(entityId: UUID) {
//        self.entityId = entityId
//    }

    func execute() -> [EffectResult] {
        return [EffectResult(entity: entity, type: .none, value: 0,
                             description: "Player ended their turn")]
    }
}
