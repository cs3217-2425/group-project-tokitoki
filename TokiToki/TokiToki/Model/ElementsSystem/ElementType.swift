//
//  ElementType.swift
//  TokiToki
//
//  Created by wesho on 17/3/25.
//

import Foundation

enum ElementType: String, CaseIterable, Codable {
    case fire = "fire"
    case water = "water"
    case earth = "earth"
    case air = "air"
    case light = "light"
    case dark = "dark"
    case neutral = "neutral"
    case lightning = "lightning"
    case ice = "ice"

    static func fromString(_ string: String) -> ElementType? {
        ElementType(rawValue: string.lowercased())
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
