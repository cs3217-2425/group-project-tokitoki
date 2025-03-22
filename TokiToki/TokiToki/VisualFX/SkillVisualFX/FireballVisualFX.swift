//
//  FireballVisualFX.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class FireballVisualFX: SkillVisualFX {
    private let sourceView: UIView
    private let targetView: UIView

    init(sourceView: UIView, targetView: UIView) {
        self.sourceView = sourceView
        self.targetView = targetView
    }

    func play(completion: @escaping () -> Void) {
        // Convert positions to window coordinates
        let sourcePosition = sourceView.convert(
            CGPoint(x: sourceView.bounds.midX, y: sourceView.bounds.midY),
            to: nil
        )
        let targetPosition = targetView.convert(
            CGPoint(x: targetView.bounds.midX, y: targetView.bounds.midY),
            to: nil
        )

        // Create fireball projectile
        let fireball = createFireballView()
        fireball.center = sourcePosition

        // Add to the main window for cross-view animation
        if let window = UIApplication.shared.windows.first {
            window.addSubview(fireball)

            // Animate fireball traveling from source to target
            UIView.animate(withDuration: 0.7, animations: {
                fireball.center = targetPosition
                // Make it grow as it travels
                fireball.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { _ in
                // Create explosion on impact
                self.createExplosion(at: targetPosition, in: window)
                fireball.removeFromSuperview()

                // Call completion handler after a short delay for explosion to finish
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    completion()
                }
            })
        } else {
            completion()
        }
    }

    private func createFireballView() -> UIView {
        let size: CGFloat = 30
        let fireballView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        fireballView.backgroundColor = .orange
        fireballView.layer.cornerRadius = size / 2

        // Add glow effect
        fireballView.layer.shadowColor = UIColor.orange.cgColor
        fireballView.layer.shadowOffset = .zero
        fireballView.layer.shadowRadius = 10
        fireballView.layer.shadowOpacity = 0.8

        // Add particle emitter for trailing fire
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: 0, y: 0)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 1, height: 1)

        let cell = CAEmitterCell()
        cell.birthRate = 50
        cell.lifetime = 0.5
        cell.velocity = 20
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.alphaSpeed = -1.0
        cell.color = UIColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 0.6).cgColor
        cell.contents = createCircleImage(diameter: 10, color: .orange).cgImage

        emitter.emitterCells = [cell]
        fireballView.layer.addSublayer(emitter)

        return fireballView
    }

    private func createExplosion(at position: CGPoint, in view: UIView) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = position
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 10, height: 10)
        emitter.renderMode = .additive

        let cell = CAEmitterCell()
        cell.birthRate = 200
        cell.lifetime = 0.7
        cell.lifetimeRange = 0.3
        cell.velocity = 50
        cell.velocityRange = 20
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.alphaSpeed = -1.0
        cell.color = UIColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 0.8).cgColor
        cell.emissionRange = .pi * 2
        cell.contents = createCircleImage(diameter: 10, color: .orange).cgImage

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)

        // Remove after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            emitter.removeFromSuperlayer()
        }
    }

    private func createCircleImage(diameter: CGFloat, color: UIColor) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
}
