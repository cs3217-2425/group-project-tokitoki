//
//  TextLabelPrimitive.swift
//  TokiToki
//
//  Created by wesho on 3/4/25.
//

import UIKit

class TextLabelPrimitive: VisualFXPrimitive {
    func apply(to view: UIView, with parameters: [String: Any], completion: @escaping () -> Void) {
        // Extract parameters with defaults
        let text = parameters["text"] as? String ?? ""
        let textColor = parameters["textColor"] as? UIColor ?? .white
        let fontSize = parameters["fontSize"] as? CGFloat ?? 16
        let fontWeight = parameters["fontWeight"] as? UIFont.Weight ?? .bold
        let duration = parameters["duration"] as? TimeInterval ?? 0.8
        let verticalOffset = parameters["verticalOffset"] as? CGFloat ?? -50
        let initialPosition = parameters["initialPosition"] as? CGPoint
        let fadeOut = parameters["fadeOut"] as? Bool ?? true
        let riseUp = parameters["riseUp"] as? Bool ?? true
        let pulsate = parameters["pulsate"] as? Bool ?? false
        let zIndex = parameters["zIndex"] as? CGFloat ?? 0

        // Create the label
        let label = UILabel()
        label.text = text
        label.textColor = textColor
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.sizeToFit()

        // Position the label
        if let position = initialPosition {
            label.center = position
        } else {
            label.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        }

        // Add to view
        view.addSubview(label)

        // Set layer zPosition if needed (to control the stacking order)
        if zIndex != 0 {
            label.layer.zPosition = zIndex
        }

        // Optional for better readability
        if let addShadow = parameters["addShadow"] as? Bool, addShadow {
            let shadowColor = parameters["shadowColor"] as? UIColor ?? .black
            let shadowOpacity = parameters["shadowOpacity"] as? Float ?? 0.8
            let shadowRadius = parameters["shadowRadius"] as? CGFloat ?? 2.0
            let shadowOffset = parameters["shadowOffset"] as? CGSize ?? CGSize(width: 1, height: 1)

            label.layer.shadowColor = shadowColor.cgColor
            label.layer.shadowOpacity = shadowOpacity
            label.layer.shadowRadius = shadowRadius
            label.layer.shadowOffset = shadowOffset
        }

        // Optional pulsate animation
        if pulsate {
            self.addPulsateAnimation(to: label)
        }

        // Main animation
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            if fadeOut {
                label.alpha = 0
            }

            if riseUp {
                label.center.y += verticalOffset
            }

        }, completion: { _ in
            label.removeFromSuperview()
            completion()
        })
    }

    private func addPulsateAnimation(to label: UILabel) {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.2, 1.0]
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.duration = 0.5
        scaleAnimation.repeatCount = 2
        
        label.layer.add(scaleAnimation, forKey: "pulsate")
    }
}
