//
//  DamageDealtVisualFX.swift
//  TokiToki
//
//  Created by wesho on 3/4/25.
//

import UIKit

protocol HitVisualFX {
    func play(amount: Int, isCritical: Bool, completion: @escaping () -> Void)
}

class DamageDealtVisualFX: HitVisualFX {
    private let targetView: UIView
    private let compositeEffect: CompositeVisualFX

    init(targetView: UIView) {
        self.targetView = targetView
        self.compositeEffect = CompositeVisualFX(sourceView: targetView, targetView: targetView)
        setupHitEffect()
    }

    private func setupHitEffect() {
        // Add red flash
        var flashParams = ColorParameters(color: .red, intensity: 0.5, fade: true).toDictionary()
        flashParams["isTargetEffect"] = true
        compositeEffect.addPrimitive(ColorFlashPrimitive(), with: flashParams)
    }

    func play(amount: Int, isCritical: Bool, completion: @escaping () -> Void) {
        // Add text labels for damage amount and "CRITICAL!" using TextLabelPrimitive
        let damageParams: [String: Any] = [
            "text": "\(amount)",
            "textColor": isCritical ? UIColor.red : UIColor.white,
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
        if isCritical {
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
        }

        // Play the composite effect
        compositeEffect.play(completion: completion)
    }
}
