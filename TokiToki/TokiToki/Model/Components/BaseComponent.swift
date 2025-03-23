//
//  BaseComponent.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

// Base Component Implementation
class BaseComponent: Component {
    let id = UUID()
    let entityId: UUID

    init(entityId: UUID) {
        self.entityId = entityId
    }
}
