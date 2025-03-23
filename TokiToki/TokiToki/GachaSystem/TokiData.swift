//
//  TokiData.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import Foundation

struct TokiData: Codable {
    let name: String
    let rarity: Int
    let baseHealth: Int
    let baseAttack: Int
    let baseDefense: Int
    let baseSpeed: Int
    let elementType: String
    let baseHeal: Int
    let baseExp: Int
}

struct TokisData: Codable {
    let tokis: [TokiData]
}



