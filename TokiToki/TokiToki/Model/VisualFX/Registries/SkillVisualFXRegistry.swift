//
//  ComponentBasedSkillVisualFXRegistry.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

class SkillVisualFXRegistry {
    static let shared = SkillVisualFXRegistry()

    private var effectFactories: [SkillVisual: (UIView, UIView) -> SkillVisualFX] = [:]

    private init() {
        registerSkillVisualFXs()
    }

    func register(skillVisual: SkillVisual, factory: @escaping (UIView, UIView) -> SkillVisualFX) {
        effectFactories[skillVisual] = factory
    }

    func createVisualFX(for skillVisual: SkillVisual, sourceView: UIView, targetView: UIView) -> SkillVisualFX? {
        if let factory = effectFactories[skillVisual] {
            return factory(sourceView, targetView)
        }
        return nil
    }

    func createVisualFX(for skillName: String, sourceView: UIView, targetView: UIView) -> SkillVisualFX? {
        // Try to map to enum first to see if there are existing skill visuals already
        if let skillVisual = SkillVisual.fromString(skillName) {
            return createVisualFX(for: skillVisual, sourceView: sourceView, targetView: targetView)
        }

        // Default fallback
        return SkillVisualFXFactory.createDefaultSkillVisualFX(
            sourceView: sourceView,
            targetView: targetView
        )
    }

    private func registerSkillVisualFXs() {
        register(skillVisual: .fireball) { sourceView, targetView in
            SkillVisualFXFactory.createFireballFX(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .fireSlash) { sourceView, targetView in
            SkillVisualFXFactory.createFireslashFX(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .excalibur) { sourceView, targetView in
            SkillVisualFXFactory.createExcaliburFX(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .iceShot) { sourceView, targetView in
            SkillVisualFXFactory.createIceShotFX(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .arrowRain) { sourceView, targetView in
            SkillVisualFXFactory.createArrowRainFX(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .lightningStorm) { sourceView, targetView in
            SkillVisualFXFactory.createLightningStorm(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .earthquake) { sourceView, targetView in
            SkillVisualFXFactory.createEarthquake(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .flameDance) { sourceView, targetView in
            SkillVisualFXFactory.createFlameDance(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .healingWave) { sourceView, targetView in
            SkillVisualFXFactory.createHealingWave(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .earthShield) { sourceView, targetView in
            SkillVisualFXFactory.createEarthShield(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .singleHeal) { sourceView, targetView in
            SkillVisualFXFactory.createHealingWave(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .waterBlast) { sourceView, targetView in
            SkillVisualFXFactory.createWaterBlastFX(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .finalJudgement) { sourceView, targetView in
            SkillVisualFXFactory.createFinalJudgementFX(sourceView: sourceView, targetView: targetView)
        }
        
        register(skillVisual: .aoeBuff) { sourceView, targetView in
            SkillVisualFXFactory.createAoEBuffFX(sourceView: sourceView, targetView: targetView)
        }
        
        register(skillVisual: .meteorShower) { sourceView, targetView in
            SkillVisualFXFactory.createMeteorShowerFX(sourceView: sourceView, targetView: targetView)
        }
        
        register(skillVisual: .thunderFlash) { sourceView, targetView in
            SkillVisualFXFactory.createThunderFlashFX(sourceView: sourceView, targetView: targetView)
        }
        
        register(skillVisual: .thunderClap) { sourceView, targetView in
            SkillVisualFXFactory.createThunderClapFX(sourceView: sourceView, targetView: targetView)
        }
        
        register(skillVisual: .basicSpell) { sourceView, targetView in
            SkillVisualFXFactory.createBasicSpellProjectileFX(sourceView: sourceView, targetView: targetView)
        }
        
        register(skillVisual: .basicAttack) { sourceView, targetView in
            SkillVisualFXFactory.createBasicAttackFX(sourceView: sourceView, targetView: targetView)
        }
        
        register(skillVisual: .basicArrow) { sourceView, targetView in
            SkillVisualFXFactory.createBasicArrowFX(sourceView: sourceView, targetView: targetView)
        }

        register(skillVisual: .acidSpray) { sourceView, targetView in
            SkillVisualFXFactory.createAcidSpray(sourceView: sourceView, targetView: targetView)
        }    }
}
