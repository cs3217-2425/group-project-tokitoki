//
//  EndTurnAction.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class EndTurnAction: Action {
    let entityId: UUID

    init(entityId: UUID) {
        self.entityId = entityId
    }

    func execute(gameState: GameState) -> [EffectResult] {
        guard let entity = gameState.getEntity(id: entityId) else {
            return [EffectResult(entity: BaseEntity(), type: .none, value: 0, description: "Invalid entity")]
        }

        return [EffectResult(entity: entity, type: .none, value: 0,
                             description: "\(entity.getName()) ended their turn")]
    }
}
