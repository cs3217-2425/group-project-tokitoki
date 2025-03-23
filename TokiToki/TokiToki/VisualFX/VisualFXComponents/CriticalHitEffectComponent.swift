//
//  CriticalHitEffectComponent.swift
//  TokiToki
//
//  Created by wesho on 23/3/25.
//

import UIKit

class CriticalHitEffectComponent: VisualFXComponent<DamageDealtEvent> {
    override func handleEvent(_ event: DamageDealtEvent) {
        guard event.isCritical else {
            return
        }

        guard let targetView = getView(for: event.targetId) else {
            return
        }

        createCriticalHitEffect(on: targetView, amount: event.amount)
    }

    private func createCriticalHitEffect(on view: UIView, amount: Int) {
        // Flash the view in red to indicate critical damage taken
        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        view.addSubview(flashView)

        // Create damage number
        let damageLabel = UILabel()
        damageLabel.text = "\(amount)"
        damageLabel.textColor = .red
        damageLabel.font = UIFont.boldSystemFont(ofSize: 24)
        damageLabel.sizeToFit()
        damageLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 30)
        view.addSubview(damageLabel)

        // Create "CRITICAL" text
        let criticalLabel = UILabel()
        criticalLabel.text = "CRITICAL!"
        criticalLabel.textColor = .yellow
        criticalLabel.font = UIFont.boldSystemFont(ofSize: 16)
        criticalLabel.sizeToFit()
        criticalLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 60)
        view.addSubview(criticalLabel)

        // Animate everything
        UIView.animate(withDuration: 0.1, animations: {
            flashView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                flashView.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    flashView.alpha = 0.5
                }, completion: { _ in
                    UIView.animate(withDuration: 0.6, animations: {
                        flashView.alpha = 0
                        damageLabel.alpha = 0
                        damageLabel.center.y -= 40
                        criticalLabel.alpha = 0
                        criticalLabel.center.y -= 40
                    }, completion: { _ in
                        flashView.removeFromSuperview()
                        damageLabel.removeFromSuperview()
                        criticalLabel.removeFromSuperview()
                    })
                })
            })
        })
    }
}
