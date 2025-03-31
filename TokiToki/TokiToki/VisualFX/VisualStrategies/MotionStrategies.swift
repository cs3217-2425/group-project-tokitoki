//
//  MotionStrategies.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

// Motion strategy protocol
protocol MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void)
}

// Default fallback strategy
class DefaultMotionStrategy: MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void) {
        // Simple fade in and out as default
        content.alpha = 0

        UIView.animate(withDuration: 0.3, animations: {
            content.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                content.alpha = 0
            }, completion: { _ in
                containerView.removeFromSuperview()
                completion()
            })
        })
    }
}

// Specific motion strategies
class LinearMotionStrategy: MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void) {
        let duration = parameters["duration"] as? TimeInterval ?? 0.5
        let startPoint = parameters["startPoint"] as? CGPoint ?? CGPoint(x: 0, y: containerView.bounds.midY)
        let endPoint = parameters["endPoint"] as? CGPoint ?? CGPoint(x: containerView.bounds.width, y: containerView.bounds.midY)

        content.center = startPoint

        UIView.animate(withDuration: duration, animations: {
            content.center = endPoint
        }, completion: { _ in
            containerView.removeFromSuperview()
            completion()
        })
    }
}

class ArcMotionStrategy: MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void) {
        let duration = parameters["duration"] as? TimeInterval ?? 0.7
        let distance = parameters["distance"] as? CGFloat ?? 100
        let startPoint = parameters["startPoint"] as? CGPoint ?? CGPoint(x: 0, y: containerView.bounds.height - 50)
        let endPoint = parameters["endPoint"] as? CGPoint ?? CGPoint(x: containerView.bounds.width, y: containerView.bounds.height - 50)
        let arcHeight = parameters["arcHeight"] as? CGFloat ?? distance

        content.center = startPoint

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            containerView.removeFromSuperview()
            completion()
        }

        let path = UIBezierPath()
        path.move(to: startPoint)

        let controlPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: min(startPoint.y, endPoint.y) - arcHeight)
        path.addQuadCurve(to: endPoint, controlPoint: controlPoint)

        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        content.layer.add(animation, forKey: "arcMotion")

        CATransaction.commit()
    }
}

class BounceMotionStrategy: MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void) {
        let duration = parameters["duration"] as? TimeInterval ?? 1.0
        let distance = parameters["distance"] as? CGFloat ?? 50
        let startY = content.frame.origin.y
        let bounceHeight = distance

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [], animations: {
            // Up
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                content.frame.origin.y = startY - bounceHeight
            }

            // Down
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2) {
                content.frame.origin.y = startY
            }

            // Small up
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.15) {
                content.frame.origin.y = startY - bounceHeight * 0.5
            }

            // Small down
            UIView.addKeyframe(withRelativeStartTime: 0.65, relativeDuration: 0.15) {
                content.frame.origin.y = startY
            }

            // Tiny up
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.1) {
                content.frame.origin.y = startY - bounceHeight * 0.25
            }

            // Final position
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                content.frame.origin.y = startY
            }

        }, completion: { _ in
            containerView.removeFromSuperview()
            completion()
        })
    }
}

class FadeInMotionStrategy: MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void) {
        let duration = parameters["duration"] as? TimeInterval ?? 0.5
        content.alpha = 0

        UIView.animate(withDuration: duration, animations: {
            content.alpha = 1
        }, completion: { _ in
            containerView.removeFromSuperview()
            completion()
        })
    }
}

class FadeOutMotionStrategy: MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void) {
        let duration = parameters["duration"] as? TimeInterval ?? 0.5
        content.alpha = 1

        UIView.animate(withDuration: duration, animations: {
            content.alpha = 0
        }, completion: { _ in
            containerView.removeFromSuperview()
            completion()
        })
    }
}

class GrowMotionStrategy: MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void) {
        let duration = parameters["duration"] as? TimeInterval ?? 0.5
        content.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        UIView.animate(withDuration: duration, animations: {
            content.transform = CGAffineTransform.identity
        }, completion: { _ in
            containerView.removeFromSuperview()
            completion()
        })
    }
}

class ShrinkMotionStrategy: MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void) {
        let duration = parameters["duration"] as? TimeInterval ?? 0.5
        content.transform = CGAffineTransform.identity

        UIView.animate(withDuration: duration, animations: {
            content.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { _ in
            containerView.removeFromSuperview()
            completion()
        })
    }
}

class OrbitMotionStrategy: MotionCreationStrategy {
    func applyMotion(to content: UIView,
                     in containerView: UIView,
                     with parameters: [String: Any],
                     completion: @escaping () -> Void) {
        let duration = parameters["duration"] as? TimeInterval ?? 1.0
        let distance = parameters["distance"] as? CGFloat ?? 50
        let centerPoint = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)
        let radius = distance

        content.center = CGPoint(x: centerPoint.x + radius, y: centerPoint.y)

        let animation = CAKeyframeAnimation(keyPath: "position")
        let circlePath = UIBezierPath(arcCenter: centerPoint,
                                      radius: radius,
                                      startAngle: 0,
                                      endAngle: .pi * 2,
                                      clockwise: true)

        animation.path = circlePath.cgPath
        animation.duration = duration
        animation.repeatCount = 1

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            containerView.removeFromSuperview()
            completion()
        }

        content.layer.add(animation, forKey: "orbitMotion")

        CATransaction.commit()
    }
}
