//
//  VisualFXBuilder.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

class VisualFXBuilder {
    var compositeEffect: CompositeVisualFX

    init(sourceView: UIView, targetView: UIView) {
        compositeEffect = CompositeVisualFX(sourceView: sourceView, targetView: targetView)
    }

    func addColorFlash(color: UIColor, intensity: CGFloat = 0.5,
                       fade: Bool = true, isTargetEffect: Bool = true) -> VisualFXBuilder {
        var parameters = ColorParameters(color: color, intensity: intensity, fade: fade).toDictionary()
        parameters["isTargetEffect"] = isTargetEffect

        compositeEffect.addPrimitive(ColorFlashPrimitive(), with: parameters)
        return self
    }

    func addShape(type: ShapeType,
                  size: CGFloat,
                  lineWidth: CGFloat = 2.0,
                  color: UIColor = .white,
                  filled: Bool = false,
                  isTargetEffect: Bool = true
    ) -> VisualFXBuilder {
        var parameters = ShapeParameters(type: type, size: size, lineWidth: lineWidth).toDictionary()
        parameters["color"] = color
        parameters["filled"] = filled
        parameters["isTargetEffect"] = isTargetEffect

        compositeEffect.addPrimitive(ShapePrimitive(), with: parameters)
        return self
    }

    func addParticles(
        type: ParticleType,
        count: Int,
        size: CGFloat,
        speed: CGFloat = 30.0,
        lifetime: TimeInterval = 0.8,
        spreadRadius: CGFloat = 50.0,
        color: UIColor = .white,
        isTargetEffect: Bool = true
    ) -> VisualFXBuilder {
        var parameters = ParticleParameters(
            type: type,
            count: count,
            size: size,
            speed: speed,
            lifetime: lifetime,
            spreadRadius: spreadRadius
        ).toDictionary()
        parameters["color"] = color
        parameters["isTargetEffect"] = isTargetEffect

        compositeEffect.addPrimitive(ParticleEmitterPrimitive(), with: parameters)
        return self
    }

    func addProjectile(
        shape: ShapeType = .circle,
        size: CGFloat = 30,
        color: UIColor = .orange,
        lineWidth: CGFloat = 2,
        filled: Bool = true,
        motionType: ProjectileType = .linear,
        duration: TimeInterval = 0.8,
        hasTrail: Bool = true,
        trailType: ParticleType? = .spark,
        trailDensity: Int = 50,
        trailColor: UIColor? = nil,
        hasImpactEffects: Bool = true,
        impactParticleType: ParticleType? = .spark,
        impactParticleCount: Int = 25,
        impactFlashColor: UIColor? = nil,
        impactFlashIntensity: CGFloat = 0.7,
        additionalParameters: [String: Any] = [:]
    ) -> VisualFXBuilder {
        let params = ProjectileParameters(
            shape: shape,
            size: size,
            color: color,
            lineWidth: lineWidth,
            filled: filled,
            motionType: motionType,
            duration: duration,
            hasTrail: hasTrail,
            trailType: trailType,
            trailDensity: trailDensity,
            trailColor: trailColor,
            hasImpactEffects: hasImpactEffects,
            impactParticleType: impactParticleType,
            impactParticleCount: impactParticleCount,
            impactFlashColor: impactFlashColor,
            impactFlashIntensity: impactFlashIntensity,
            additionalParameters: additionalParameters
        )

        compositeEffect.addPrimitive(ProjectilePrimitive(), with: ["parameters": params])
        return self
    }

    func build() -> SkillVisualFX {
        compositeEffect
    }
}
