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
    
    static func fromString(_ string: String) -> ElementType? {
        return ElementType.allCases.first { $0.rawValue == string.lowercased() }
    }
}
