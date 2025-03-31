//
//  ShapePrimitive.swift
//  TokiToki
//
//  Created by wesho on 30/3/25.
//

import UIKit

class ShapePrimitive: VisualFXPrimitive {
    func apply(to view: UIView, with parameters: [String: Any], completion: @escaping () -> Void) {
        guard let shapeTypeString = parameters["shapeType"] as? String,
              let shapeType = ShapeParameters.ShapeType(rawValue: shapeTypeString),
              let size = parameters["size"] as? CGFloat,
              let lineWidth = parameters["lineWidth"] as? CGFloat else {
            completion()
            return
        }

        let color = parameters["color"] as? UIColor ?? .white
        let filled = parameters["filled"] as? Bool ?? false

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = view.bounds
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = filled ? color.cgColor : UIColor.clear.cgColor

        // Use strategy pattern instead of switch-cases
        let strategy = ShapeStrategyRegistry.shared.getStrategy(for: shapeType)
        let rect = CGRect(x: (view.bounds.width - size) / 2,
                          y: (view.bounds.height - size) / 2,
                          width: size, height: size)
        shapeLayer.path = strategy.createPath(in: rect)

        view.layer.addSublayer(shapeLayer)

        // Animate the shape
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.3
        shapeLayer.add(animation, forKey: "strokeEnd")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            let fadeOut = CABasicAnimation(keyPath: "opacity")
//            fadeOut.fromValue = 1
//            fadeOut.toValue = 0
//            fadeOut.duration = 0.2
//            fadeOut.fillMode = .forwards
//            fadeOut.isRemovedOnCompletion = false
//
//            shapeLayer.add(fadeOut, forKey: "fadeOut")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                shapeLayer.removeFromSuperlayer()
                completion()
            }
        }
    }
}
