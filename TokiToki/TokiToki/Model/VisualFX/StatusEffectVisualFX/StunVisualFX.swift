//
//  StunVisualFX.swift
//  TokiToki
//
//  Created by wesho on 11/4/25.
//

import UIKit

class StunVisualFX: StatusEffectVisualFX {
    private let targetView: UIView
    private let compositeEffect: CompositeVisualFX

    init(targetView: UIView) {
        self.targetView = targetView

        self.compositeEffect = CompositeVisualFX(sourceView: targetView, targetView: targetView)

        setupStunEffect()
    }

    private func setupStunEffect() {
        let stunColor = UIColor.yellow

        // Add stun color flash
        var flashParams = ColorParameters(color: stunColor, intensity: 0.4, fade: true).toDictionary()
        flashParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ColorFlashPrimitive(), with: flashParams)

        // Add "STUN" text using TextLabelPrimitive
        let textParams: [String: Any] = [
            "text": "STUN",
            "textColor": stunColor,
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

        // Add star particles
        var particleParams = ParticleParameters(
            type: .star,
            count: 40,
            size: 4,
            speed: 25,
            lifetime: 0.8,
            spreadRadius: targetView.bounds.width
        ).toDictionary()
        particleParams["color"] = stunColor
        particleParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ParticleEmitterPrimitive(), with: particleParams)
    }

    func play(completion: @escaping () -> Void) {
        compositeEffect.play(completion: completion)
    }
}
