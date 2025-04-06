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
