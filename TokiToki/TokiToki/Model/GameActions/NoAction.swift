//
//  NoAction.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class NoAction: Action {
    let entity: GameStateEntity

    init(entity: GameStateEntity) {
        self.entity = entity
    }

    func execute() -> [EffectResult] {
        [EffectResult(entity: BaseEntity(), value: 0,
                      description: "No action taken by \(entity.name)")]
    }
}
