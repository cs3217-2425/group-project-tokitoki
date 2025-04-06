//
//  RarityEnum.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//
import Foundation

enum ItemRarity: String, Codable, CaseIterable {
    case common = "common"
    case rare = "rare"
    case epic = "epic"

    var value: Int {
        switch self {
        case .common: return 0
        case .rare: return 1
        case .epic: return 2
        }
    }

    init?(intValue: Int) {
        switch intValue {
        case 0: self = .common
        case 1: self = .rare
        case 2: self = .epic
        default: return nil
        }
    }
}
