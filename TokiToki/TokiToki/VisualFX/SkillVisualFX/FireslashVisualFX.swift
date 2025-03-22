//
//  FireslashVisualFX.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class FireslashEffect: SkillVisualFX {
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

        if let window = UIApplication.shared.windows.first {
            // Create and animate the X slash
            createXSlash(from: sourcePosition, to: targetPosition, in: window)

            // Call completion after animation finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                completion()
            }
        } else {
            completion()
        }
    }

    private func createXSlash(from source: CGPoint, to target: CGPoint, in view: UIView) {
        // Create two slash lines forming an X
        let slash1 = createSlashLine()
        let slash2 = createSlashLine()

        view.addSubview(slash1)
        view.addSubview(slash2)

        // Position slashes initially at source
        slash1.center = source
        slash2.center = source

        // Rotate slash2 to form an X
        slash2.transform = CGAffineTransform(rotationAngle: .pi / 2)

        // Calculate direction vector
        let dx = target.x - source.x
        let dy = target.y - source.y

        // Calculate rotation to face target
        let angle = atan2(dy, dx)

        // Apply rotation to both slashes
        slash1.transform = CGAffineTransform(rotationAngle: angle)
        slash2.transform = CGAffineTransform(rotationAngle: angle + .pi / 2)

        // Animate slashes moving to target with fading
        UIView.animate(withDuration: 0.5, animations: {
            slash1.center = target
            slash2.center = target
            slash1.transform = slash1.transform.scaledBy(x: 2.0, y: 2.0)
            slash2.transform = slash2.transform.scaledBy(x: 2.0, y: 2.0)
        }, completion: { _ in
            // Create impact flash
            self.createImpactFlash(at: target, in: view)

            // Fade out slashes
            UIView.animate(withDuration: 0.3, animations: {
                slash1.alpha = 0
                slash2.alpha = 0
            }, completion: { _ in
                slash1.removeFromSuperview()
                slash2.removeFromSuperview()
            })
        })
    }

    private func createSlashLine() -> UIView {
        let slashView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 8))
        slashView.backgroundColor = UIColor.orange
        slashView.layer.cornerRadius = 4

        // Add glow effect
        slashView.layer.shadowColor = UIColor.orange.cgColor
        slashView.layer.shadowOffset = .zero
        slashView.layer.shadowRadius = 8
        slashView.layer.shadowOpacity = 0.8

        return slashView
    }

    private func createImpactFlash(at position: CGPoint, in view: UIView) {
        let flashView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        flashView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        flashView.center = position
        flashView.layer.cornerRadius = 40
        view.addSubview(flashView)

        // Flash animation
        UIView.animate(withDuration: 0.1, animations: {
            flashView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                flashView.alpha = 0
            }, completion: { _ in
                flashView.removeFromSuperview()
            })
        })
    }
}
