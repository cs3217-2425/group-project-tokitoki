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

        // Fire color
        let fireColor = UIColor.orange

        return builder
            .addProjectile(
                shape: .circle,
                size: 30,
                color: fireColor,
                filled: true,
                motionType: .linear,
                duration: 0.8,
                trailType: .smoke,
                impactParticleType: .spark
            )
            .build()
    }

    static func createFireslashFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        // Fire color
        let fireColor = UIColor.orange

        return builder
            // Source effect - sword charges
            .addColorFlash(color: fireColor, intensity: 0.3, fade: true, isTargetEffect: false)

            // Target impact effects
            .addShape(type: .x, size: 80, lineWidth: 4, color: fireColor, isTargetEffect: true)
            .addColorFlash(color: fireColor, intensity: 0.5, isTargetEffect: true)

            .beginConcurrentGroup()
            .addParticles(type: .circle, count: 25, size: 8, speed: 35,
                          lifetime: 0.6, color: fireColor, isTargetEffect: true)

            .build()
    }

    static func createExcaliburFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            .addParticles(type: .triangle, count: 50, size: 2, speed: 100,
                          lifetime: 0.4, spreadRadius: 200, color: .white, isTargetEffect: true)
            .beginConcurrentGroup()
            .addShape(type: .line, size: 250, color: .white)
            .addParticles(type: .spark, count: 50, size: 4, speed: 20,
                          lifetime: 0.8, color: .orange, isTargetEffect: true)
            .build()
    }

    static func createIceShotFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            .addProjectile(
                shape: .line,
                size: 50,
                color: .cyan,
                filled: true,
                motionType: .linear,
                duration: 0.8,
                trailType: .triangle,
                trailDensity: 20,
                impactParticleType: .spark
            )
            .build()
    }

    static func createArrowRainFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            .addProjectile(
                shape: .line,
                size: 20,
                color: .white,
                filled: true,
                motionType: .linear,
                duration: 0.4
            )
            .beginConcurrentGroup()
            .addParticles(type: .triangle, count: 50, size: 2, speed: 100,
                          lifetime: 0.4, spreadRadius: 200, color: .white, isTargetEffect: true)
            .build()
    }

    static func createLightningStorm(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            .addColorFlash(color: .purple, intensity: 0.2, fade: true, isTargetEffect: true)
            .beginConcurrentGroup()
            .addColorFlash(color: .white, intensity: 0.5, fade: true, isTargetEffect: true)
            .beginConcurrentGroup()
            .addColorFlash(color: .yellow, intensity: 0.3, fade: true, isTargetEffect: true)
            .build()
    }

    // Method to create default effect
    static func createDefaultSkillVisualFX(
        sourceView: UIView,
        targetView: UIView
    ) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            .addColorFlash(color: .red, intensity: 0.5, isTargetEffect: true)
            .build()
    }
}
