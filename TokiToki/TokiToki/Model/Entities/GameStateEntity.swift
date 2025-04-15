//
//  BaseEntity.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

class GameStateEntity: BaseEntity {
    var name: String
    var toki: Toki

    init(_ name: String, _ toki: Toki) {
        self.name = name
        self.toki = toki
        super.init()
    }

    func getName() -> String {
        name
    }
}
