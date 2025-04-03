//
//  ParticleEmitterPrimitive.swift
//  TokiToki
//
//  Created by wesho on 30/3/25.
//

import UIKit

class ParticleEmitterPrimitive: VisualFXPrimitive {
    func apply(to view: UIView, with parameters: [String: Any], completion: @escaping () -> Void) {
        guard let particleTypeString = parameters["particleType"] as? String,
              let particleType = ParticleType(rawValue: particleTypeString),
              let count = parameters["count"] as? Int,
              let size = parameters["size"] as? CGFloat,
              let speed = parameters["speed"] as? CGFloat,
              let lifetime = parameters["lifetime"] as? TimeInterval,
              let spreadRadius = parameters["spreadRadius"] as? CGFloat else {
            completion()
            return
        }

        let color = parameters["color"] as? UIColor ?? .white

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        emitter.emitterSize = CGSize(width: spreadRadius, height: spreadRadius)
        emitter.emitterShape = .circle
        emitter.renderMode = .additive

        let cell = CAEmitterCell()
        cell.birthRate = Float(count)
        cell.lifetime = Float(lifetime)
        cell.velocity = speed
        cell.velocityRange = speed / 2
        cell.emissionRange = .pi * 2
        cell.scale = size / 10
        cell.scaleRange = size / 20
        cell.color = color.cgColor
        cell.alphaSpeed = -1.0

        // Use strategy pattern instead of switch
        let strategy = ParticleStrategyRegistry.shared.getStrategy(for: particleType)
        let image = strategy.createImage(size: CGSize(width: 20, height: 20), color: color)
        cell.contents = image.cgImage

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Stop emitting new particles
            emitter.birthRate = 0

            // Remove emitter after all particles are gone
            DispatchQueue.main.asyncAfter(deadline: .now() + lifetime) {
                emitter.removeFromSuperlayer()
                completion()
            }
        }
    }
}
