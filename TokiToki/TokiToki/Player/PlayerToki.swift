//
//  PlayerToki.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//
import Foundation

struct PlayerToki {
    let id: UUID
    let baseTokiId: UUID
    let dateAcquired: Date
    
    init(id: UUID = UUID(), baseTokiId: UUID, dateAcquired: Date = Date()) {
        self.id = id
        self.baseTokiId = id
        self.dateAcquired = dateAcquired
    }
}

