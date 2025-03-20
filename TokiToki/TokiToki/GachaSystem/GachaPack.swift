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
    
    init(id: UUID = UUID(), name: String, containedTokis: [Toki]) {
        self.id = id
        self.name = name
        self.containedTokis = containedTokis
    }
}

