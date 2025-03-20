//
//  GachaService.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import Foundation

class GachaService {
    private let gachaRepository: GachaRepository
    
    init(gachaRepository: GachaRepository) {
        self.gachaRepository = gachaRepository
    }

    func drawPack(packId: UUID, for player: inout Player) -> [PlayerToki] {
        guard let pack = gachaRepository.findPack(by: packId) else {
            print("GachaService: No pack found with ID \(packId)")
            return []
        }
        
        let newPlayerTokis: [PlayerToki] = pack.containedTokis.map { definition in
            PlayerToki(
                id: UUID(),
                baseTokiId: definition.id,
                dateAcquired: Date()
            )
        }
        
        player.ownedTokis.append(contentsOf: newPlayerTokis)
        
        return newPlayerTokis
    }
}
