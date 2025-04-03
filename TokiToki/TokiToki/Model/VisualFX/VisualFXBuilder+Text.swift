//
//  VisualFXBuilder+Text.swift
//  TokiToki
//
//  Created by wesho on 3/4/25.
//

import UIKit

extension VisualFXBuilder {
    // Basic text label
    func addTextLabel(
        text: String,
        color: UIColor = .white,
        fontSize: CGFloat = 16,
        fontWeight: UIFont.Weight = .bold,
        position: CGPoint? = nil,
        duration: TimeInterval = 0.8,
        fadeOut: Bool = true,
        riseUp: Bool = true,
        isTargetEffect: Bool = true
    ) -> VisualFXBuilder {
        var parameters: [String: Any] = [
            "text": text,
            "textColor": color,
            "fontSize": fontSize,
            "fontWeight": fontWeight,
            "duration": duration,
            "fadeOut": fadeOut,
            "riseUp": riseUp,
            "isTargetEffect": isTargetEffect
        ]

        if let position = position {
            parameters["initialPosition"] = position
        }

        compositeEffect.addPrimitive(TextLabelPrimitive(), with: parameters)
        return self
    }

    // Add damage numbers
    func addDamageNumber(
        amount: Int,
        isCritical: Bool = false,
        position: CGPoint? = nil,
        isTargetEffect: Bool = true
    ) -> VisualFXBuilder {
        let fontSize: CGFloat = isCritical ? 24 : 20
        let color: UIColor = isCritical ? .red : .white
        let yOffset: CGFloat = isCritical ? -60 : -30

        var calculatedPosition: CGPoint?
        if let basePosition = position {
            calculatedPosition = CGPoint(x: basePosition.x, y: basePosition.y + yOffset)
        }

        // Add damage number
        _ = addTextLabel(
            text: "\(amount)",
            color: color,
            fontSize: fontSize,
            position: calculatedPosition,
            fadeOut: true,
            riseUp: true,
            isTargetEffect: isTargetEffect
        )

        // Critical hit
        if isCritical {
            var criticalPosition: CGPoint?
            if let basePosition = position {
                criticalPosition = CGPoint(x: basePosition.x, y: basePosition.y - 30)
            }

            _ = addTextLabel(
                text: "CRITICAL!",
                color: .yellow,
                fontSize: 16,
                position: criticalPosition,
                fadeOut: true,
                riseUp: true,
                isTargetEffect: isTargetEffect
            )
        }

        return self
    }

    // Status effect labels
    func addStatusEffectLabel(
        effectName: String,
        color: UIColor,
        position: CGPoint? = nil,
        isTargetEffect: Bool = true
    ) -> VisualFXBuilder {
        var calculatedPosition: CGPoint?
        if let basePosition = position {
            calculatedPosition = CGPoint(x: basePosition.x, y: basePosition.y - 30)
        }

        _ = addTextLabel(
            text: effectName.uppercased(),
            color: color,
            fontSize: 18,
            position: calculatedPosition,
            duration: 0.8,
            fadeOut: true,
            riseUp: true,
            isTargetEffect: isTargetEffect
        )

        return self
    }
}
