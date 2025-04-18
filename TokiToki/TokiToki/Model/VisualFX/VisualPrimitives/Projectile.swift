//
//  Projectile.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

// Projectile class for handling projectile creation and motion
class Projectile {
    private let sourceView: UIView
    private let targetView: UIView
    private let parameters: ProjectileParameters
    private var projectileView: UIView?
    private var trailEmitter: CAEmitterLayer?
    private let logger = Logger(subsystem: "Projectile")

    init(sourceView: UIView, targetView: UIView, parameters: ProjectileParameters) {
        self.sourceView = sourceView
        self.targetView = targetView
        self.parameters = parameters
    }

    func launch(completion: @escaping () -> Void) {
        // Find the key window to add our projectile to
        guard let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first else {
            logger.logError("Could not find window")
            completion()
            return
        }

        // Convert source and target positions to window coordinates
        let sourcePositionInWindow = sourceView.convert(
            CGPoint(x: sourceView.bounds.midX, y: sourceView.bounds.midY),
            to: window)

        let targetPositionInWindow = targetView.convert(
            CGPoint(x: targetView.bounds.midX, y: targetView.bounds.midY),
            to: window)

        // Create the main projectile view (the center visual shape)
        let projectileView = createProjectileView()
        self.projectileView = projectileView

        // Set initial position in window
        projectileView.center = sourcePositionInWindow
        window.addSubview(projectileView)

        // Add trail if enabled
        if parameters.hasTrail, let trailType = parameters.trailType {
            addTrail(to: projectileView, type: trailType)
        }

        // DIRECT ANIMATION
        UIView.animate(withDuration: parameters.duration, animations: {
            // Move to target
            projectileView.center = targetPositionInWindow

            // Scale up during movement
            let scaleAmount = self.parameters.additionalParameters["scaleAmount"] as? CGFloat ?? 1.3
            projectileView.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)

        }, completion: { finished in
            if finished {
                // Show impact effects
                if self.parameters.hasImpactEffects {
                    self.showImpactEffects(at: targetPositionInWindow, in: window)
                }

                // Fade out projectile
                UIView.animate(withDuration: 0.2, animations: {
                    projectileView.alpha = 0
                }, completion: { _ in
                    projectileView.removeFromSuperview()
                    completion()
                })
            } else {
                projectileView.removeFromSuperview()
                completion()
            }
        })
    }

    private func createProjectileView() -> UIView {
        let projectileContainer = UIView(frame: CGRect(
            x: 0, y: 0, width: parameters.size, height: parameters.size
        ))
        projectileContainer.backgroundColor = .clear

        // Create shape using strategy
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = projectileContainer.bounds
        shapeLayer.strokeColor = parameters.color.cgColor
        shapeLayer.lineWidth = parameters.lineWidth
        shapeLayer.fillColor = parameters.filled ? parameters.color.cgColor : UIColor.clear.cgColor

        // Use shape strategy to create the main shape
        let strategy = ShapeStrategyRegistry.shared.getStrategy(for: parameters.shape)
        shapeLayer.path = strategy.createPath(in: projectileContainer.bounds)

        projectileContainer.layer.addSublayer(shapeLayer)

        // Add glow effect
        if parameters.filled {
            projectileContainer.layer.shadowColor = parameters.color.cgColor
            projectileContainer.layer.shadowOffset = .zero
            projectileContainer.layer.shadowRadius = 8
            projectileContainer.layer.shadowOpacity = 0.7
        }

        return projectileContainer
    }

    private func addTrail(to projectileView: UIView, type: ParticleType) {
        // Create emitter layer
        let emitter = CAEmitterLayer()

        // Position emitter at the center of the projectile
        emitter.emitterPosition = CGPoint(x: projectileView.bounds.width / 2, y: projectileView.bounds.height / 2)

        // Set emitter properties for a wider spread of particles
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: parameters.size * 5.0, height: parameters.size * 5.0)
        emitter.renderMode = .additive

        // Create the particle cell
        let cell = CAEmitterCell()

        // Settings to spread particles more widely
        cell.birthRate = Float(parameters.trailDensity)
        cell.lifetime = 0.8
        cell.lifetimeRange = 0.4

        // Increase velocity and range significantly for wider spread
        cell.velocity = 25
        cell.velocityRange = 15
        cell.emissionRange = .pi * 2

        // Add some radial acceleration to push particles outward
        cell.xAcceleration = 20
        cell.yAcceleration = 20
        cell.emissionLongitude = .pi  // Emit in opposite direction of travel

        // Size settings
        cell.scale = 0.3
        cell.scaleRange = 0.2
        cell.scaleSpeed = -0.1  // Shrink over time

        // Color and alpha
        let trailColor = parameters.trailColor ?? parameters.color
        cell.color = trailColor.cgColor
        cell.alphaSpeed = -1.0

        // Add some spin for more dynamic effect
        cell.spin = 1.5
        cell.spinRange = 3.0

        // Use the appropriate particle image
        let strategy = ParticleStrategyRegistry.shared.getStrategy(for: type)
        let particleImage = strategy.createImage(size: CGSize(width: 10, height: 10), color: trailColor)
        cell.contents = particleImage.cgImage

        // Set the cells to the emitter
        emitter.emitterCells = [cell]

        // Add emitter behind the projectile for better layering
        if let firstSublayer = projectileView.layer.sublayers?.first {
            projectileView.layer.insertSublayer(emitter, below: firstSublayer)
        } else {
            projectileView.layer.addSublayer(emitter)
        }

    }
    private func showImpactEffects(at position: CGPoint, in window: UIView) {
        // Add flash effect in the window at target position
        let flashColor = parameters.impactFlashColor ?? parameters.color
        let flashSize: CGFloat = parameters.size * 3
        let flashView = UIView(frame: CGRect(
            x: position.x - flashSize / 2,
            y: position.y - flashSize / 2,
            width: flashSize,
            height: flashSize
        ))
        flashView.backgroundColor = flashColor.withAlphaComponent(parameters.impactFlashIntensity)
        flashView.layer.cornerRadius = flashSize / 2
        window.addSubview(flashView)

        UIView.animate(withDuration: 0.3, animations: {
            flashView.alpha = 0
            flashView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            flashView.removeFromSuperview()
        })

        // Add particle burst
        if let particleType = parameters.impactParticleType {
            let emitter = CAEmitterLayer()
            emitter.emitterPosition = position
            emitter.emitterSize = CGSize(width: 10, height: 10)
            emitter.emitterShape = .circle
            emitter.renderMode = .additive

            let cell = CAEmitterCell()
            cell.birthRate = Float(parameters.impactParticleCount * 5)  // High birth rate for burst
            cell.lifetime = 0.7
            cell.lifetimeRange = 0.3
            cell.velocity = 50
            cell.velocityRange = 20
            cell.emissionRange = .pi * 2
            cell.scale = 0.7
            cell.scaleRange = 0.3

            // Use color of projectile or specific impact color
            let impactColor = parameters.impactFlashColor ?? parameters.color
            cell.color = impactColor.cgColor
            cell.alphaSpeed = -1.5

            // Use particle strategy to create the right image
            let strategy = ParticleStrategyRegistry.shared.getStrategy(for: particleType)
            let particleImage = strategy.createImage(size: CGSize(width: 10, height: 10), color: impactColor)
            cell.contents = particleImage.cgImage

            emitter.emitterCells = [cell]
            window.layer.addSublayer(emitter)

            // Stop emission after a short burst
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                emitter.birthRate = 0

                // Remove emitter after particles fade
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    emitter.removeFromSuperlayer()
                }
            }
        }
    }
}
