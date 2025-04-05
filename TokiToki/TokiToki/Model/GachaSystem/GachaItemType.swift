//
//  GachaItemType.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//
import Foundation

enum GachaItemType: String, CaseIterable {
    case toki
    case skill
    case equipment

    static func fromString(_ string: String) -> GachaItemType? {
        GachaItemType.allCases.first { $0.rawValue == string.lowercased() }
    }
}
