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
                size: 40,
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

    static func createFlameDance(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        let fireColor = UIColor.orange

        return builder
            .addParticles(type: .smoke, count: 20, size: 15, speed: 20,
                          lifetime: 0.4, spreadRadius: 400, color: fireColor, isTargetEffect: true)
            .addParticles(type: .spark, count: 30, size: 10, speed: 30,
                          lifetime: 0.4, spreadRadius: 400, color: fireColor, isTargetEffect: false)
            .build()
    }

    static func createHealingWave(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            .addColorFlash(color: .green, intensity: 0.2, fade: true, isTargetEffect: true)
            .addParticles(type: .spark, count: 50, size: 2, speed: 30,
                          lifetime: 0.4, spreadRadius: 200, isTargetEffect: true)
            .build()
    }

    static func createEarthquake(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            .addColorFlash(color: .red, intensity: 0.2, fade: true, isTargetEffect: true)
            .addParticles(type: .circle, count: 50, size: 4, speed: 50,
                          lifetime: 0.2, spreadRadius: 200, color: .brown, isTargetEffect: true)
            .beginConcurrentGroup()
            .addColorFlash(color: .brown, intensity: 0.5, fade: true, isTargetEffect: true)
            .addParticles(type: .circle, count: 50, size: 2, speed: 50,
                          lifetime: 0.3, spreadRadius: 200, color: .brown, isTargetEffect: true)
            .beginConcurrentGroup()
            .addColorFlash(color: .red, intensity: 0.3, fade: true, isTargetEffect: true)
            .addParticles(type: .circle, count: 70, size: 1, speed: 50,
                          lifetime: 0.5, spreadRadius: 200, color: .brown, isTargetEffect: true)
            .build()
    }

    static func createEarthShield(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            .addShape(type: .circle, size: 150, color: .brown, filled: true)
            .addParticles(type: .circle, count: 70, size: 1, speed: 50,
                          lifetime: 0.5, spreadRadius: 200, color: .brown, isTargetEffect: true)
            .beginConcurrentGroup()
            .addColorFlash(color: .green)
            .build()
    }

    static func createAcidSpray(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        return builder
            .addProjectile(
                shape: .circle,
                size: 0,
                color: .purple,
                filled: true,
                motionType: .linear,
                duration: 0.8,
                trailType: .circle,
                trailDensity: 20,
                trailColor: .purple,
                impactParticleType: .bubble,
                impactParticleCount: 20,
                impactFlashColor: .purple
            )
            .build()
    }

    static func createWaterBlastFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        // Water colors
        let waterColor = UIColor.cyan.withAlphaComponent(0.8)
        let deepWaterColor = UIColor(red: 0, green: 0.4, blue: 0.8, alpha: 0.9)

        return builder
            .addProjectile(
                shape: .circle,
                size: 35,
                color: waterColor,
                filled: true,
                motionType: .arc,
                duration: 0.7,
                trailType: .bubble,
                trailDensity: 15,
                trailColor: waterColor,
                impactParticleType: nil,
                impactParticleCount: 30,
                impactFlashColor: deepWaterColor
            )
            .beginConcurrentGroup()
            .addColorFlash(color: waterColor, intensity: 0.3, fade: true, isTargetEffect: true)
            .addParticles(type: .bubble, count: 40, size: 5, speed: 45,
                          lifetime: 0.8, spreadRadius: 160, color: waterColor, isTargetEffect: true)
            .build()
    }

    static func createFinalJudgementFX(sourceView: UIView, targetView: UIView) -> SkillVisualFX {
        let builder = VisualFXBuilder(sourceView: sourceView, targetView: targetView)

        // Holy/judgment colors - gold with hints of blue to distinguish from Excalibur
        let goldColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        let blueGoldColor = UIColor(red: 0.9, green: 0.8, blue: 0.4, alpha: 1.0)

        return builder
            // Initial effect - charging judgment power
            .addColorFlash(color: goldColor, intensity: 0.4, fade: true, isTargetEffect: false)

            // Main sword strike effect - similar to Excalibur but with gold color
            .addParticles(type: .triangle, count: 60, size: 3, speed: 120,
                          lifetime: 0.5, spreadRadius: 220, color: goldColor, isTargetEffect: true)
            .beginConcurrentGroup()
            .addShape(type: .line, size: 300, lineWidth: 5, color: blueGoldColor)
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
