//
//  ParalysisVisualFX.swift
//  TokiToki
//
//  Created by wesho on 11/4/25.
//

import UIKit

class ParalysisVisualFX: StatusEffectVisualFX {
    private let targetView: UIView
    private let compositeEffect: CompositeVisualFX

    init(targetView: UIView) {
        self.targetView = targetView

        // Create a composite effect using the target view as both source and target
        // Status effects only need one view
        self.compositeEffect = CompositeVisualFX(sourceView: targetView, targetView: targetView)

        // Build the paralysis effect using primitives
        setupParalysisEffect()
    }

    private func setupParalysisEffect() {
        let electricColor = UIColor.yellow

        var flashParams = ColorParameters(color: electricColor, intensity: 0.5, fade: true).toDictionary()
        flashParams["isTargetEffect"] = true
        flashParams["flashCount"] = 3
        flashParams["flashInterval"] = 0.15
        compositeEffect.addPrimitive(ColorFlashPrimitive(), with: flashParams)

        // Add "PARALYSIS" text using TextLabelPrimitive
        let textParams: [String: Any] = [
            "text": "PARALYSIS",
            "textColor": electricColor,
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
    }

    func play(completion: @escaping () -> Void) {
        compositeEffect.play(completion: completion)
    }
}
