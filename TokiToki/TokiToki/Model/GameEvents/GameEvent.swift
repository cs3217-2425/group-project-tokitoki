//
//  GameEvent.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import Foundation

protocol GameEvent {
    var timestamp: Date { get }
}

extension GameEvent {
    var timestamp: Date {
        Date()
    }
}

struct GachaPullEvent: GameEvent {
    let itemName: String
    let rarity: ItemRarity
}
