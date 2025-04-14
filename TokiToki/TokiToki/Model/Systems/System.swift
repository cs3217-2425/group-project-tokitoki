//
//  System.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

import Foundation

protocol System {
    func update(_ entities: [GameStateEntity])
    func reset(_ entities: [GameStateEntity])
}
