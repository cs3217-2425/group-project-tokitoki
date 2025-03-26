//
//  GachaPack.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import Foundation

struct GachaPack {
    let id: UUID
    let name: String
    let containedTokis: [Toki]
    let rarityDropRates: [TokiRarity: Double]

    init(id: UUID = UUID(), name: String, containedTokis: [Toki], rarityDropRates: [TokiRarity: Double]) {
        self.id = id
        self.name = name
        self.containedTokis = containedTokis
        self.rarityDropRates = rarityDropRates
    }
}
