//
//  BurnVisualFX.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class BurnVisualFX: StatusEffectVisualFX {
    private let targetView: UIView
    private let compositeEffect: CompositeVisualFX

    init(targetView: UIView) {
        self.targetView = targetView

        // Create a composite effect using the target view as both source and target
        // Status effects only need one view
        self.compositeEffect = CompositeVisualFX(sourceView: targetView, targetView: targetView)

        // Build the burn effect using primitives
        setupBurnEffect()
    }

    private func setupBurnEffect() {
        let fireColor = UIColor.orange

        // Add fire color flash
        var flashParams = ColorParameters(color: fireColor, intensity: 0.4, fade: true).toDictionary()
        flashParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ColorFlashPrimitive(), with: flashParams)

        // Add "BURN" text using TextLabelPrimitive
        let textParams: [String: Any] = [
            "text": "BURN",
            "textColor": fireColor,
            "fontSize": 18.0,
            "fontWeight": UIFont.Weight.bold,
            "duration": 0.8,
            "fadeOut": true,
            "riseUp": true,
            "verticalOffset": -50.0,
            "isTargetEffect": true,
            "addShadow": true
        ]
        compositeEffect.addPrimitive(TextLabelPrimitive(), with: textParams)

        // Add fire particles
        var particleParams = ParticleParameters(
            type: .spark,
            count: 50,
            size: 10,
            speed: 30,
            lifetime: 0.8,
            spreadRadius: targetView.bounds.width
        ).toDictionary()
        particleParams["color"] = UIColor.orange
        particleParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ParticleEmitterPrimitive(), with: particleParams)

        // Add additional smoke particles
        var smokeParams = ParticleParameters(
            type: .smoke,
            count: 30,
            size: 15,
            speed: 20,
            lifetime: 1.0,
            spreadRadius: targetView.bounds.width
        ).toDictionary()
        smokeParams["color"] = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.6)
        smokeParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ParticleEmitterPrimitive(), with: smokeParams)
    }

    func play(completion: @escaping () -> Void) {
        compositeEffect.play(completion: completion)
    }
}
