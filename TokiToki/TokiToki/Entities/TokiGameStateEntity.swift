//
//  PlayerEntity.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

class TokiGameStateEntity: GameStateEntity {
    var name: String

    init(name: String) {
        self.name = name
        super.init()
    }

    override func getName() -> String {
        name
    }
}
