//
//  BattleScreenViewController+animations.swift
//  TokiToki
//
//  Created by proglab on 15/4/25.
//

import UIKit

extension BattleScreenViewController {
    internal func moveTokiView(_ tokiView: UIView, _ isAlly: Bool, _ leftPosition: CGFloat,
                                  _ rightPosition: CGFloat, _ originalPosition: CGFloat,
                                  _ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            tokiView.frame.origin.x = isAlly ? leftPosition : rightPosition
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                tokiView.frame.origin.x = originalPosition
            }, completion: { _ in
                completion()
            })
        }
    }

    internal func animateMovement(_ tokiView: UIView, _ completion: @escaping () -> Void, _ isAlly: Bool) {
        let originalPosition = tokiView.frame.origin.x
        let rightPosition = tokiView.frame.origin.x + 50
        let leftPosition = tokiView.frame.origin.x - 50
        let delay: TimeInterval = 0.4

        if isAlly {
            moveTokiView(tokiView, isAlly, leftPosition, rightPosition, originalPosition, completion)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.moveTokiView(tokiView, isAlly, leftPosition, rightPosition, originalPosition, completion)
            }
        }
    }

    func showUseSkill(_ id: UUID, _ isAlly: Bool, completion: @escaping () -> Void = {}) {
        let tokiView = gameStateIdToViews[id]
        guard let tokiView = tokiView else {
            completion()
            return
        }

        animateMovement(tokiView.overallView, completion, isAlly)
    }
    
    func showRevive(_ id: UUID) {
        guard let view = gameStateIdToViews[id]?.overallView else { return }

        view.isHidden = false
        view.alpha = 1.0
        view.transform = .identity

        // FLASH: White light burst overlay
        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = UIColor.white
        flashView.alpha = 0
        view.addSubview(flashView)
        view.bringSubviewToFront(flashView)

        UIView.animate(withDuration: 0.1, animations: {
            flashView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.4, animations: {
                flashView.alpha = 0.0
            }) { _ in
                flashView.removeFromSuperview()
            }
        }

        // GLOW: Outer aura
        view.layer.shadowColor = UIColor.yellow.cgColor
        view.layer.shadowRadius = 30
        view.layer.shadowOpacity = 1.0
        view.layer.shadowOffset = .zero

        // PULSE
        view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut], animations: {
            view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                view.transform = .identity
            }
        }

        // PARTICLES
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 30, height: 30)

        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "peg-green@1x")?.withTintColor(.yellow, renderingMode: .alwaysOriginal).cgImage
        cell.birthRate = 100
        cell.lifetime = 1.2
        cell.velocity = 60
        cell.scale = 0.04
        cell.alphaSpeed = -0.6
        cell.emissionRange = .pi * 2

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            emitter.birthRate = 0
            emitter.removeFromSuperlayer()
            view.layer.shadowOpacity = 0.0
            view.layer.shadowRadius = 0.0
            view.layer.shadowColor = nil
        }
    }
}
