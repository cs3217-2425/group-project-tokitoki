//
//  GachaRepository.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import Foundation

class GachaRepository {
    
    // Full catalog of Tokis
    var allTokis: [Toki] = []
    
    // All available packs
    var gachaPacks: [GachaPack] = []
    
    // Example: Simple method to find a pack by its UUID
    func findPack(by id: UUID) -> GachaPack? {
        return gachaPacks.first { $0.id == id }
    }
    
    // You could add more methods here to filter packs, add new packs, etc.
}
