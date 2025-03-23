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
    let baseHeal: Int
    let baseExp: Int
    let elementType: String
}

struct TokisData: Codable {
    let tokis: [TokiData]
}



