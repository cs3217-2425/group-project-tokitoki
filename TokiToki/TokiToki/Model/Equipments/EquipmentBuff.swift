//
//  Buff.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation

/// Represents a buff that modifies one or more stats.
struct EquipmentBuff {
    /// The different stats that can be buffed.
    enum Stat: String, Codable, CaseIterable {
        case attack, defense, speed
    }

    let value: Int
    let description: String
    let affectedStats: [Stat]

    init(value: Int,
                description: String,
                affectedStats: [Stat]) {
        self.value = value
        self.description = description
        self.affectedStats = affectedStats
    }
}
