//
//  ElementType.swift
//  TokiToki
//
//  Created by wesho on 17/3/25.
//

import Foundation

enum ElementType: String, CaseIterable {
    case fire
    case water
    case earth
    case air
    case light
    case dark
    case neutral
    case lightning
    case ice

    static func fromString(_ string: String) -> ElementType? {
        ElementType.allCases.first { $0.rawValue == string.lowercased() }
    }
}
