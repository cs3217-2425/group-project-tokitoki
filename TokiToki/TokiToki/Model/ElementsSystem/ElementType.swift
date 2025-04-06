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
    
    var description: String {
        switch self {
        case .fire: return "Fire"
        case .water: return "Water"
        case .earth: return "Earth"
        case .air: return "Air"
        case .light: return "Light"
        case .dark: return "Dark"
        case .neutral: return "Neutral"
        case .lightning: return "Lightning"
        case .ice: return "Ice"
        }
    }
}
