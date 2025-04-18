//
//  BattleScreenViewController+updateViews.swift
//  TokiToki
//
//  Created by proglab on 15/4/25.
//

import UIKit

extension BattleScreenViewController {
    func update(log: [String]) {
        let numberOfLinesToDisplay = 3
        let logToDisplay = log.count > numberOfLinesToDisplay ?
                            Array(log[(log.count - numberOfLinesToDisplay)...]) : log
        battleLogDisplay.text = logToDisplay.joined(separator: "\n")
    }

    

    internal func removeCooldownOverlay(_ skillImageView: UIImageView) {
        skillImageView.subviews.forEach { $0.removeFromSuperview() }
    }

    func updateSkillIcons(_ icons: [SkillUiInfo]?) {
        guard let icons = icons else {
            return
        }
        playerActionImageViews.forEach { $0.isHidden = false }
        if skillImageViews.count > icons.count {
            for i in icons.count..<skillImageViews.count {
                skillImageViews[i].isHidden = true
            }
        }

        for i in 0..<icons.count {
            let skillImageView = skillImageViews[i]
            skillImageView.image = UIImage(named: icons[i].iconImgString)
            skillImageView.isUserInteractionEnabled = icons[i].cooldown == 0

            if icons[i].cooldown > 0 {
                removeCooldownOverlay(skillImageView)
                let overlay = UIView(frame: skillImageView.bounds)
                overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                skillImageView.addSubview(overlay)

                let cooldownLabel = UILabel(frame: skillImageView.bounds)
                cooldownLabel.text = "\(icons[i].cooldown)"
                cooldownLabel.textAlignment = .center
                cooldownLabel.textColor = .white
                cooldownLabel.font = UIFont.boldSystemFont(ofSize: 20)
                skillImageView.addSubview(cooldownLabel)
            } else {
                removeCooldownOverlay(skillImageView)
            }
        }
    }
    
    func showWhoseTurn(_ id: UUID) {
        guard let view = gameStateIdToViews[id] else { return }
        let currentView = view.overallView

        // Remove all previous indicators
        for (_, v) in gameStateIdToViews {
            v.overallView.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        }

        // Load arrow image
        let arrowImage = UIImage(named: "downArrow.png")
        let arrowSize = CGSize(width: 24, height: 24)
        let arrowImageView = UIImageView(image: arrowImage)
        arrowImageView.frame = CGRect(
            x: (currentView.bounds.width - arrowSize.width) / 2,
            y: -arrowSize.height - view.name.frame.height / 2,
            width: arrowSize.width,
            height: arrowSize.height
        )
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tag = 999
        arrowImageView.alpha = 0.95

        // Optional: Add a glow effect
        arrowImageView.layer.shadowColor = UIColor.yellow.cgColor
        arrowImageView.layer.shadowRadius = 5
        arrowImageView.layer.shadowOpacity = 0.8
        arrowImageView.layer.shadowOffset = .zero

        currentView.addSubview(arrowImageView)
    }

    func updateHealthBar(_ id: UUID, _ currentHealth: Int, _ maxHealth: Int,
                         completion: @escaping () -> Void) {
        let healthPercentage = CGFloat(currentHealth) / CGFloat(maxHealth)
        let healthBar = gameStateIdToViews[id]?.healthBar
        let healthContainerWidth = gameStateIdToViews[id]?.healthContainer.bounds.width

        guard let healthBar = healthBar, let healthContainerWidth = healthContainerWidth else {
            return
        }

        UIView.animate(withDuration: 0.3, animations: {
            healthBar.frame.size.width = healthContainerWidth * healthPercentage
        }, completion: { _ in
            completion()
        })

        if healthPercentage > 0.5 {
            healthBar.backgroundColor = .green
        } else if healthPercentage > 0.25 {
            healthBar.backgroundColor = .yellow
        } else {
            healthBar.backgroundColor = .red
        }
    }
    
    func removeDeadBody(_ id: UUID) {
        gameStateIdToViews[id]?.overallView.isHidden = true
    }
}
