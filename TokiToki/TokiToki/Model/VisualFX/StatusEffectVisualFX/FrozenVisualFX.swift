//
//  FrozenVisualFX.swift
//  TokiToki
//
//  Created by wesho on 11/4/25.
//

import UIKit

class FrozenVisualFX: StatusEffectVisualFX {
    private let targetView: UIView
    private let compositeEffect: CompositeVisualFX

    init(targetView: UIView) {
        self.targetView = targetView

        self.compositeEffect = CompositeVisualFX(sourceView: targetView, targetView: targetView)

        setupFrozenEffect()
    }

    private func setupFrozenEffect() {
        let iceColor = UIColor(red: 0.8, green: 0.95, blue: 1.0, alpha: 1.0)
        let frostColor = UIColor(red: 0.5, green: 0.8, blue: 0.9, alpha: 1.0)

        var flashParams = ColorParameters(color: iceColor, intensity: 0.5, fade: true).toDictionary()
        flashParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ColorFlashPrimitive(), with: flashParams)

        // Add "FROZEN" text using TextLabelPrimitive
        let textParams: [String: Any] = [
            "text": "FROZEN",
            "textColor": frostColor,
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

        // Add ice crystal particles
        var crystalParams = ParticleParameters(
            type: .triangle,
            count: 40,
            size: 5,
            speed: 15,
            lifetime: 2.0,
            spreadRadius: targetView.bounds.width
        ).toDictionary()
        crystalParams["color"] = iceColor
        crystalParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ParticleEmitterPrimitive(), with: crystalParams)
    }

    func play(completion: @escaping () -> Void) {
        compositeEffect.play(completion: completion)
    }
}
