//
//  VisualFXBuilder.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

class VisualFXBuilder {
    private var compositeEffect: CompositeVisualFX

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

    func addShape(type: ShapeParameters.ShapeType,
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
        type: ParticleParameters.ParticleType,
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

    func addMotion(
        type: MotionParameters.MotionType,
        duration: TimeInterval,
        distance: CGFloat,
        startPoint: CGPoint? = nil,
        endPoint: CGPoint? = nil,
        content: UIView? = nil,
        contentSize: CGSize? = nil,
        color: UIColor = .white,
        isTargetEffect: Bool = false
    ) -> VisualFXBuilder {
        var parameters = MotionParameters(type: type, duration: duration, distance: distance).toDictionary()

        if let startPoint = startPoint {
            parameters["startPoint"] = startPoint
        }

        if let endPoint = endPoint {
            parameters["endPoint"] = endPoint
        }

        if let content = content {
            parameters["content"] = content
        }

        if let contentSize = contentSize {
            parameters["contentSize"] = contentSize
        }

        parameters["color"] = color
        parameters["isTargetEffect"] = isTargetEffect

        compositeEffect.addPrimitive(MotionPrimitive(), with: parameters)
        return self
    }

    func build() -> SkillVisualFX {
        compositeEffect
    }
}
