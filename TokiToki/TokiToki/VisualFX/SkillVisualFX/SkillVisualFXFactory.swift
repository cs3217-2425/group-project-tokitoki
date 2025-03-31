//
//  SkillVisualFXFactory.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

class SkillVisualFXFactory {
    static func createFireballFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            // Source effect - fireball appears
            .addShape(type: .circle, size: 30, lineWidth: 2, color: .orange, filled: true, isTargetEffect: false)
            .addParticles(type: .spark, count: 20, size: 10, speed: 20,
                          lifetime: 0.5, color: .orange, isTargetEffect: false)

            // Travel effect - fireball moves to target
            .addMotion(type: .linear, duration: 0.8, distance: 0,
                       startPoint: CGPoint(x: sourceView.bounds.midX, y: sourceView.bounds.midY),
                       endPoint: CGPoint(x: targetView.bounds.midX, y: targetView.bounds.midY),
                       contentSize: CGSize(width: 30, height: 30), color: .orange)

            // Target impact effects
            .addColorFlash(color: .orange, intensity: 0.7)
            .addParticles(type: .spark, count: 30, size: 10, speed: 40, lifetime: 0.7, color: .orange)

            .build()
    }

    static func createFireslashFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            // Source effect - sword charges
            .addColorFlash(color: .orange, intensity: 0.3, fade: true, isTargetEffect: false)

            // Target impact effects
            .addShape(type: .x, size: 80, lineWidth: 4, color: .orange)
            .addColorFlash(color: .orange, intensity: 0.5)
            .addParticles(type: .circle, count: 25, size: 8, speed: 35, lifetime: 0.6, color: .orange)

            .build()
    }

    static func createIceslashFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        let iceBlue = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)

        return builder
            // Source effect
            .addColorFlash(color: iceBlue, intensity: 0.3, fade: true, isTargetEffect: false)

            // Target impact effects
            .addShape(type: .x, size: 80, lineWidth: 4, color: iceBlue)
            .addColorFlash(color: iceBlue, intensity: 0.5)
            .addParticles(type: .triangle, count: 25, size: 8, speed: 35, lifetime: 0.6, color: iceBlue)

            .build()
    }

    static func createThunderboltFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        let thunderYellow = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)

        return builder
            // First flash
            .addColorFlash(color: thunderYellow, intensity: 0.8, fade: true)

            // Lightning shape
            .addShape(type: .line, size: 100, lineWidth: 5, color: thunderYellow)

            // Second flash
            .addColorFlash(color: .white, intensity: 0.6, fade: true)

            // Particles
            .addParticles(type: .spark, count: 25, size: 10, speed: 50, lifetime: 0.5, color: thunderYellow)

            .build()
    }

    // Method to create any effect based on parameters
    static func createVisualFX(
        sourceView: UIView,
        targetView: UIView,
        shapeType: ShapeParameters.ShapeType,
        color: UIColor,
        particleType: ParticleParameters.ParticleType
    ) -> SkillVisualFX {
        var builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        // Source effect
        builder = builder.addColorFlash(color: color, intensity: 0.3, fade: true, isTargetEffect: false)

        // Target effects
        builder = builder.addShape(type: shapeType, size: 60, lineWidth: 3, color: color)
        builder = builder.addColorFlash(color: color, intensity: 0.5)
        builder = builder.addParticles(type: particleType, count: 25, size: 8, speed: 35, lifetime: 0.6, color: color)

        return builder.build()
    }
}
