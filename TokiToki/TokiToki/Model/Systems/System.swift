//
//  System.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

protocol System {
    var priority: Int { get }
    // func update(_ entities: [GameStateEntity])
    func reset(_ entities: [GameStateEntity])
}
