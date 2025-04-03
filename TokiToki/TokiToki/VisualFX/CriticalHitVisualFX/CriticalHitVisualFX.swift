//
//  CriticalHitVisualFX.swift
//  TokiToki
//
//  Created by wesho on 3/4/25.
//

import UIKit

protocol HitVisualFX {
    func play(amount: Int, completion: @escaping () -> Void)
}

class CriticalHitVisualFX: HitVisualFX {
    private let targetView: UIView
    private let compositeEffect: CompositeVisualFX

    init(targetView: UIView) {
        self.targetView = targetView
        self.compositeEffect = CompositeVisualFX(sourceView: targetView, targetView: targetView)
        setupCriticalHitEffect()
    }

    private func setupCriticalHitEffect() {
        // Add red flash
        var flashParams = ColorParameters(color: .red, intensity: 0.5, fade: true).toDictionary()
        flashParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ColorFlashPrimitive(), with: flashParams)

        // Add X shape
        var shapeParams = ShapeParameters(type: .x, size: 80, lineWidth: 3).toDictionary()
        shapeParams["color"] = UIColor.red
        shapeParams["filled"] = false
        shapeParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ShapePrimitive(), with: shapeParams)

        // Add particles
        var particleParams = ParticleParameters(
            type: .spark,
            count: 30,
            size: 8,
            speed: 40,
            lifetime: 0.6,
            spreadRadius: 60
        ).toDictionary()
        particleParams["color"] = UIColor.red
        particleParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ParticleEmitterPrimitive(), with: particleParams)
    }

    func play(amount: Int, completion: @escaping () -> Void) {
        // Add text labels for damage amount and "CRITICAL!" using TextLabelPrimitive
        let damageParams: [String: Any] = [
            "text": "\(amount)",
            "textColor": UIColor.red,
            "fontSize": 24.0,
            "fontWeight": UIFont.Weight.bold,
            "duration": 0.8,
            "fadeOut": true,
            "riseUp": true,
            "verticalOffset": -40.0,
            "initialPosition": CGPoint(x: targetView.bounds.midX, y: targetView.bounds.midY - 30),
            "isTargetEffect": true,
            "addShadow": true,
            "pulsate": true
        ]
        compositeEffect.addPrimitive(TextLabelPrimitive(), with: damageParams)

        // "CRITICAL!" label using TextLabelPrimitive
        let criticalParams: [String: Any] = [
            "text": "CRITICAL!",
            "textColor": UIColor.yellow,
            "fontSize": 16.0,
            "fontWeight": UIFont.Weight.bold,
            "duration": 0.8,
            "fadeOut": true,
            "riseUp": true,
            "verticalOffset": -40.0,
            "initialPosition": CGPoint(x: targetView.bounds.midX, y: targetView.bounds.midY - 60),
            "isTargetEffect": true,
            "addShadow": true
        ]
        compositeEffect.addPrimitive(TextLabelPrimitive(), with: criticalParams)

        // Play the composite effect
        compositeEffect.play(completion: completion)
    }
}
