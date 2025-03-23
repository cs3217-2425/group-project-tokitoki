//
//  Component.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

protocol Component {
    var id: UUID { get }
    var entityId: UUID { get }
}
