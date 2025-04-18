//
//  BattleScreenViewController+onTap.swift
//  TokiToki
//
//  Created by proglab on 15/4/25.
//

import Foundation
import UIKit

extension BattleScreenViewController {
    @objc func skillTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        playerActionImageViews.forEach { $0.isHidden = true }
        gameEngine?.useTokiSkill(tappedImageView.tag)
    }

    @objc func opponentTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        let targetId = opponentImageViewsToId[tappedImageView]
        guard let targetId = targetId else {
            return
        }
        gameEngine?.useSingleTargetTokiSkill(targetId)

        for imageView in opponentImageViews {
            imageView.layer.removeAllAnimations()
            imageView.alpha = 1.0
            imageView.isUserInteractionEnabled = false
        }
    }

    @objc func playerTokiTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        let targetId = playerImageViewsToId[tappedImageView]
        guard let targetId = targetId else {
            return
        }
        gameEngine?.useSingleTargetTokiSkill(targetId)

        for imageView in playerTokisImageViews {
            imageView.layer.removeAllAnimations()
            imageView.alpha = 1.0
            imageView.isUserInteractionEnabled = false
        }
    }

    func allowOpponentTargetSelection() {
        opponentImageViews.forEach { imageView in
            UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction]) {
                imageView.alpha = 0.5
            }
            imageView.isUserInteractionEnabled = true
        }
    }

    func allowAllyTargetSelection() {
        playerTokisImageViews.forEach { imageView in
            UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction]) {
                imageView.alpha = 0.5
            }
            imageView.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func onRestart(_ sender: Any) {
        self.gameEngine?.restart()
        for imageView in skillImageViews {
            removeCooldownOverlay(imageView)
        }
        for view in gameStateIdToViews.values {
            view.overallView.isHidden = false
        }
    }

    @objc func useConsumables(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }

        let items = gameEngine?.countConsumables() ?? []
 
        let alert = UIAlertController(title: "Use Consumable", message: "Choose an item to use:", preferredStyle: .actionSheet)

        for item in items where item.quantity > 0 {
            let action = UIAlertAction(title: "\(item.name) x\(item.quantity)", style: .default) { _ in
                self.gameEngine?.useConsumable(item.name)
            }
            alert.addAction(action)
        }

        if alert.actions.isEmpty {
            alert.message = "You have no usable consumables."
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        // Present from image view location (for iPad compatibility)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = tappedView
            popoverController.sourceRect = tappedView.bounds
        }

        self.present(alert, animated: true)
    }

    @objc func takeNoAction(_ sender: UITapGestureRecognizer) {
        playerActionImageViews.forEach { $0.isHidden = true }
        gameEngine?.takeNoAction()
    }
}
