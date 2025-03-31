//
//  VisualFXPrimitive.swift
//  TokiToki
//
//  Created by wesho on 30/3/25.
//

import UIKit

// Base protocol for a single VFX component
protocol VisualFXPrimitive {
    func apply(to view: UIView, with parameters: [String: Any], completion: @escaping () -> Void)
}

// Parameters structs for common effect components
struct ColorParameters {
    let color: UIColor
    let intensity: CGFloat
    let fade: Bool

    func toDictionary() -> [String: Any] {
        [
            "color": color,
            "intensity": intensity,
            "fade": fade
        ]
    }
}

struct ShapeParameters {
    enum ShapeType: String {
        case circle,
             square,
             triangle,
             x,
             line,
             arc,
             spiral,
             star
    }

    let type: ShapeType
    let size: CGFloat
    let lineWidth: CGFloat

    func toDictionary() -> [String: Any] {
        [
            "shapeType": type.rawValue,
            "size": size,
            "lineWidth": lineWidth
        ]
    }
}

struct ParticleParameters {
    enum ParticleType: String {
        case circle, square, triangle, spark, smoke, bubble
    }

    let type: ParticleType
    let count: Int
    let size: CGFloat
    let speed: CGFloat
    let lifetime: TimeInterval
    let spreadRadius: CGFloat

    func toDictionary() -> [String: Any] {
        [
            "particleType": type.rawValue,
            "count": count,
            "size": size,
            "speed": speed,
            "lifetime": lifetime,
            "spreadRadius": spreadRadius
        ]
    }
}

struct MotionParameters {
    enum MotionType: String {
        case linear, arc, bounce, fadeIn, fadeOut, grow, shrink, orbit
    }

    let type: MotionType
    let duration: TimeInterval
    let distance: CGFloat
    
    func toDictionary() -> [String: Any] {
        [
            "motionType": type.rawValue,
            "duration": duration,
            "distance": distance
        ]
    }
}
