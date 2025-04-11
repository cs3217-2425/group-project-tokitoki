//
//  PoisonVisualFX.swift
//  TokiToki
//
//  Created by wesho on 11/4/25.
//

import UIKit

class PoisonVisualFX: StatusEffectVisualFX {
    private let targetView: UIView
    private let compositeEffect: CompositeVisualFX

    init(targetView: UIView) {
        self.targetView = targetView

        self.compositeEffect = CompositeVisualFX(sourceView: targetView, targetView: targetView)

        setupPoisonEffect()
    }

    private func setupPoisonEffect() {
        let poisonColor = UIColor(red: 0.7, green: 0.2, blue: 0.8, alpha: 1.0)

        var flashParams = ColorParameters(color: poisonColor, intensity: 0.4, fade: true).toDictionary()
        flashParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ColorFlashPrimitive(), with: flashParams)

        // Add "POISON" text using TextLabelPrimitive
        let textParams: [String: Any] = [
            "text": "POISON",
            "textColor": poisonColor,
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

        // Add toxic bubble particles
        var bubbleParams = ParticleParameters(
            type: .bubble,
            count: 20,
            size: 8,
            speed: 20,
            lifetime: 1.2,
            spreadRadius: targetView.bounds.width * 0.8
        ).toDictionary()
        bubbleParams["color"] = poisonColor
        bubbleParams["isTargetEffect"] = true
        bubbleParams["riseFactor"] = 1.5
        compositeEffect.addPrimitive(ParticleEmitterPrimitive(), with: bubbleParams)
        
        var smokeParams = ParticleParameters(
            type: .smoke,
            count: 25,
            size: 15,
            speed: 15,
            lifetime: 1.0,
            spreadRadius: targetView.bounds.width
        ).toDictionary()
        smokeParams["color"] = poisonColor.withAlphaComponent(0.5)
        smokeParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ParticleEmitterPrimitive(), with: smokeParams)
    }

    func play(completion: @escaping () -> Void) {
        compositeEffect.play(completion: completion)
    }
}
