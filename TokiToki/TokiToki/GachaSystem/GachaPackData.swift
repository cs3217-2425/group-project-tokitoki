//
//  GachaPackData.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 21/3/25.
//
import Foundation

struct GachaPackData: Codable {
    let packName: String
    let tokiNames: [String]
}

struct GachaPacksData: Codable {
    let packs: [GachaPackData]
}

