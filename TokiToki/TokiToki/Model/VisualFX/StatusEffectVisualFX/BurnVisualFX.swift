//
//  BurnVisualFX.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class BurnVisualFX: StatusEffectVisualFX {
    private let targetView: UIView

    init(targetView: UIView) {
        self.targetView = targetView
    }

    func play(completion: @escaping () -> Void) {
        // Create a burst of fire particles
        let emitter = createFireEmitter()
        targetView.layer.addSublayer(emitter)

        // Show damage number
        let damageLabel = UILabel()
        damageLabel.text = "BURN"
        damageLabel.textColor = .orange
        damageLabel.font = UIFont.boldSystemFont(ofSize: 18)
        damageLabel.sizeToFit()
        damageLabel.center = CGPoint(x: targetView.bounds.midX, y: targetView.bounds.midY - 30)
        targetView.addSubview(damageLabel)

        // Animate the damage text rising and fading
        UIView.animate(withDuration: 0.8, animations: {
            damageLabel.alpha = 0
            damageLabel.center.y -= 50
        }, completion: { _ in
            damageLabel.removeFromSuperview()
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            emitter.removeFromSuperlayer()
            completion()
        }
    }

    private func createFireEmitter() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: targetView.bounds.midX, y: targetView.bounds.midY)
        emitter.emitterSize = CGSize(width: targetView.bounds.width, height: targetView.bounds.height)
        emitter.emitterShape = .rectangle
        emitter.renderMode = .additive

        let cell = CAEmitterCell()
        cell.birthRate = 100
        cell.lifetime = 0.8
        cell.lifetimeRange = 0.3
        cell.velocity = 30
        cell.velocityRange = 20
        cell.emissionRange = .pi * 2
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.color = UIColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 0.8).cgColor
        cell.alphaSpeed = -1.0

        let image = createCircleImage(diameter: 10, color: .orange)
        cell.contents = image.cgImage

        emitter.emitterCells = [cell]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            emitter.birthRate = 0
        }

        return emitter
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
