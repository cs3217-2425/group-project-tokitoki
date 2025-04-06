//
//  BaseEntity.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Base Entity Implementation
class GameStateEntity: BaseEntity {
    var name: String

    init(_ name: String) {
        self.name = name
        super.init()
    }

    func getName() -> String {
        name
    }
}
