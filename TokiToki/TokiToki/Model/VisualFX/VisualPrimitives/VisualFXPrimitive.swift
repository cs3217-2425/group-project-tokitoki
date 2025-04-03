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

struct ProjectileParameters {
    // Basic appearance, the main projectile
    let shape: ShapeType
    let size: CGFloat
    let color: UIColor
    let lineWidth: CGFloat
    let filled: Bool

    // Motion parameters
    let motionType: ProjectileType
    let duration: TimeInterval

    // Trail effect
    let hasTrail: Bool
    let trailType: ParticleType?
    let trailDensity: Int
    let trailColor: UIColor?

    // Impact effects, visual upon impact
    let hasImpactEffects: Bool
    let impactParticleType: ParticleType?
    let impactParticleCount: Int
    let impactFlashColor: UIColor?
    let impactFlashIntensity: CGFloat

    // Additional parameters for specific motion types
    var additionalParameters: [String: Any]

    // Initialization with default values
    init(
        shape: ShapeType = .circle,
        size: CGFloat = 30,
        color: UIColor = .white,
        lineWidth: CGFloat = 2,
        filled: Bool = true,
        motionType: ProjectileType = .linear,
        duration: TimeInterval = 1.0,
        hasTrail: Bool = false,
        trailType: ParticleType?,
        trailDensity: Int = 50,
        trailColor: UIColor? = nil,
        hasImpactEffects: Bool = false,
        impactParticleType: ParticleType?,
        impactParticleCount: Int = 25,
        impactFlashColor: UIColor? = nil,  // Default to projectile color if nil
        impactFlashIntensity: CGFloat = 0.7,
        additionalParameters: [String: Any] = [:]
    ) {
        self.shape = shape
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
        self.filled = filled
        self.motionType = motionType
        self.duration = duration
        self.hasTrail = hasTrail
        self.trailType = trailType
        self.trailDensity = trailDensity
        self.trailColor = trailColor
        self.hasImpactEffects = hasImpactEffects
        self.impactParticleType = impactParticleType
        self.impactParticleCount = impactParticleCount
        self.impactFlashColor = impactFlashColor
        self.impactFlashIntensity = impactFlashIntensity

        // Add default scale effect if not specified
        var updatedParams = additionalParameters
        if updatedParams["scaleEffect"] == nil {
            updatedParams["scaleEffect"] = true
        }
        if updatedParams["scaleAmount"] == nil {
            updatedParams["scaleAmount"] = 1.3
        }
        self.additionalParameters = updatedParams
    }
}
