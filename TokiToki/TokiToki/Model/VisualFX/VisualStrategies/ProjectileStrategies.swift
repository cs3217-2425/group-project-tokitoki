//
//  ProjectileStrategies.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

// Protocol for projectile motion strategies
protocol ProjectileStrategy {
    func applyProjectileMotion(
        projectileView: UIView,
        from sourcePoint: CGPoint,
        to targetPoint: CGPoint,
        with parameters: [String: Any],
        completion: @escaping () -> Void
    )
}

enum ProjectileType: String {
    case linear
    case arc
}

// Strategy for linear projectile motion
class LinearProjectileStrategy: ProjectileStrategy {
    func applyProjectileMotion(
        projectileView: UIView,
        from sourcePoint: CGPoint,
        to targetPoint: CGPoint,
        with parameters: [String: Any],
        completion: @escaping () -> Void
    ) {
        let duration = parameters["duration"] as? TimeInterval ?? 0.8

        // Make sure initial position is set correctly
        projectileView.center = sourcePoint

        // Optional scaling effect during animation
        let scaleEffect = parameters["scaleEffect"] as? Bool ?? true
        let scaleAmount = parameters["scaleAmount"] as? CGFloat ?? 1.3

        UIView.animate(withDuration: duration, animations: {
            // Move to target
            projectileView.center = targetPoint

            // Optional scale effect
            if scaleEffect {
                projectileView.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
            }
        }, completion: { finished in
            if finished {
                completion()
            }
        })
    }
}

// Strategy for arc projectile motion
class ArcProjectileStrategy: ProjectileStrategy {
    func applyProjectileMotion(
        projectileView: UIView,
        from sourcePoint: CGPoint,
        to targetPoint: CGPoint,
        with parameters: [String: Any],
        completion: @escaping () -> Void
    ) {
        let duration = parameters["duration"] as? TimeInterval ?? 0.8
        let arcHeight = parameters["arcHeight"] as? CGFloat ?? 100.0

        // Make sure initial position is set correctly
        projectileView.center = sourcePoint

        // Optional scaling effect during animation
        let scaleEffect = parameters["scaleEffect"] as? Bool ?? true
        let scaleAmount = parameters["scaleAmount"] as? CGFloat ?? 1.3

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if scaleEffect {
                // Ensure scale is applied by completion
                projectileView.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
            }
            completion()
        }

        // Create the arc path
        let path = UIBezierPath()
        path.move(to: sourcePoint)

        let controlPoint = CGPoint(
            x: (sourcePoint.x + targetPoint.x) / 2,
            y: min(sourcePoint.y, targetPoint.y) - arcHeight
        )
        path.addQuadCurve(to: targetPoint, controlPoint: controlPoint)

        // Set up the path animation
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Apply the animation
        projectileView.layer.add(animation, forKey: "arcMotion")

        // Apply scale if needed
        if scaleEffect {
            UIView.animate(withDuration: duration) {
                projectileView.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
            }
        }

        // Update the model value to match final position
        projectileView.center = targetPoint

        CATransaction.commit()
    }
}
