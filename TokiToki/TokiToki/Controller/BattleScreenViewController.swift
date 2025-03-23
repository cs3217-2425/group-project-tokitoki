//
//  BattleScreenViewController.swift
//  TokiToki
//
//  Created by proglab on 20/3/25.
//

import UIKit

class BattleScreenViewController: UIViewController, BattleLogObserver, BattleEffectsDelegate {
    private var gameEngine: GameEngine?
    private var skillImageViews: [UIImageView] = []
    private var playerTokisViews: [Views] = []
    private var opponentTokisViews: [Views] = []
    private var gameStateIdToViews: [UUID: Views] = [:]
    private var opponentImageViews: [UIImageView] = []
    private var opponentImageViewsToId: [UIImageView: UUID] = [:]

    @IBOutlet var toki1HealthBarContainer: UIView!
    @IBOutlet var toki1HealthBar: UIView!
    @IBOutlet var toki1View: UIView!

    @IBOutlet var toki2HealthBarContainer: UIView!
    @IBOutlet var toki2HealthBar: UIView!
    @IBOutlet var toki2View: UIView!

    @IBOutlet var toki3HealthBar: UIView!
    @IBOutlet var toki3HealthBarContainer: UIView!
    @IBOutlet var toki3View: UIView!

    @IBOutlet var mainOppHealthBarContainer: UIView!
    @IBOutlet var mainOppHealthBar: UIView!
    @IBOutlet var mainOpponentView: UIView!

    @IBOutlet var opponent2HealthBar: UIView!
    @IBOutlet var opponent2HealthBarContainer: UIView!
    @IBOutlet var opponent2View: UIView!

    @IBOutlet var opponent3HealthBar: UIView!
    @IBOutlet var opponent3HealthBarContainer: UIView!
    @IBOutlet var opponent3View: UIView!

    @IBOutlet var skill1: UIImageView!
    @IBOutlet var skill2: UIImageView!
    @IBOutlet var skill3: UIImageView!
    @IBOutlet var opponent1: UIImageView!
    @IBOutlet var opponent2: UIImageView!
    @IBOutlet var opponent3: UIImageView!
    @IBOutlet var toki1: UIImageView!
    @IBOutlet var toki2: UIImageView!
    @IBOutlet var toki3: UIImageView!
    @IBOutlet var battleLogDisplay: UILabel!
    @IBOutlet var logBackground: UIView!

    func configure(_ playerTokis: [Toki], _ opponentEntities: [GameStateEntity]) {
        let playerEntities = createPlayerEntitiesAndAddMappingToView(playerTokis)
        hideTokisIfNoTokiInThatSlot(playerEntities, playerTokisViews)
        hideTokisIfNoTokiInThatSlot(opponentEntities, opponentTokisViews)
        addMappingOfOpponentEntitiesToImageView(opponentEntities)

        self.gameEngine = GameEngine(playerTeam: playerEntities, opponentTeam: opponentEntities)
        self.gameEngine?.addObserver(self)
        self.gameEngine?.addDelegate(self)
        self.gameEngine?.startBattle()
    }

    fileprivate func createPlayerEntitiesAndAddMappingToView(_ playerTokis: [Toki]) -> [GameStateEntity] {
        playerTokis.enumerated().map { index, toki in
            let entity = toki.createBattleEntity()
            gameStateIdToViews[entity.id] = playerTokisViews[index]
            return entity
        }
    }

    fileprivate func addMappingOfOpponentEntitiesToImageView(_ opponentEntities: [GameStateEntity]) {
        for (index, opponent) in opponentEntities.enumerated() {
            gameStateIdToViews[opponent.id] = opponentTokisViews[index]
            opponentImageViewsToId[opponentImageViews[index]] = opponent.id
        }
    }

    fileprivate func hideTokisIfNoTokiInThatSlot(_ entities: [GameStateEntity], _ views: [Views]) {
        if views.count > entities.count {
            for i in entities.count..<views.count {
                views[i].overallView.isHidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSkillIcons()

        configureViews()
        configureLogBackground()

        addGestureRecognisers()

        configure([knightToki, wizardToki], [basicMonster])
    }

    fileprivate func configureSkillIcons() {
        skillImageViews = [skill1, skill2, skill3]
        for skillView in skillImageViews {
            skillView.layer.borderWidth = 2
            skillView.layer.borderColor = UIColor.white.cgColor
            skillView.backgroundColor = .red
            skillView.layer.cornerRadius = 15
            skillView.clipsToBounds = true
        }
    }

    fileprivate func configureViews() {
        playerTokisViews = [Views(overallView: toki1View, healthBar: toki1HealthBar, healthContainer: toki1HealthBarContainer),
                            Views(overallView: toki2View, healthBar: toki2HealthBar, healthContainer: toki2HealthBarContainer),
                            Views(overallView: toki3View, healthBar: toki3HealthBar, healthContainer: toki3HealthBarContainer)]
        opponentTokisViews = [Views(overallView: mainOpponentView, healthBar: mainOppHealthBar, healthContainer: mainOppHealthBarContainer),
                              Views(overallView: opponent2View, healthBar: opponent2HealthBar, healthContainer: opponent2HealthBarContainer),
                              Views(overallView: opponent3View, healthBar: opponent3HealthBar, healthContainer: opponent3HealthBarContainer)]

        opponentImageViews = [opponent1, opponent2, opponent3]
    }

    fileprivate func configureLogBackground() {
        logBackground.layer.cornerRadius = 10
        logBackground.layer.borderColor = UIColor.white.cgColor
        logBackground.layer.borderWidth = 2
    }

    fileprivate func addGestureRecognisers() {
        for (index, skillImageView) in skillImageViews.enumerated() {
            skillImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(skillTapped(_:)))
            skillImageView.addGestureRecognizer(tapGesture)
            skillImageView.tag = index
        }

        for imageView in opponentImageViews {
            imageView.isUserInteractionEnabled = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(opponentTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
        }
    }

    @objc func skillTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        skillImageViews.forEach { $0.isHidden = true }
        gameEngine?.useTokiSkill(tappedImageView.tag, nil)
    }

    @objc func opponentTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        // opponentTokisViews[tappedImageView] TODO: allow tapping of opp for selection
    }

    func update(log: [String]) {
        let numberOfLinesToDisplay = 3
        let logToDisplay = log.count > numberOfLinesToDisplay ?
                            Array(log[(log.count - numberOfLinesToDisplay)...]) : log
        battleLogDisplay.text = logToDisplay.joined(separator: "\n")
    }

    fileprivate func animateMovement(_ tokiView: UIView, _ completion: @escaping () -> Void, _ isLeft: Bool) {
        let originalPosition = tokiView.frame.origin.x
        let rightPosition = tokiView.frame.origin.x + 50
        let leftPosition = tokiView.frame.origin.x - 50
        UIView.animate(withDuration: 0.5, animations: {
            if isLeft {
                tokiView.frame.origin.x = leftPosition
            } else {
                tokiView.frame.origin.x = rightPosition
            }

        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                tokiView.frame.origin.x = originalPosition
            }, completion: { _ in
                completion()
            })
        }
    }

    func showUseSkill(_ id: UUID, _ isLeft: Bool, completion: @escaping () -> Void = {}) {
        let tokiView = gameStateIdToViews[id]
        guard let tokiView = tokiView else {
            completion()
            return
        }

        animateMovement(tokiView.overallView, completion, isLeft)
    }

    func updateSkillIcons(_ icons: [SkillUiInfo]?) {
        guard let icons = icons else {
            return
        }
        skillImageViews.forEach { $0.isHidden = false }
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
                // Darken the image
                let overlay = UIView(frame: skillImageView.bounds)
                overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 50% dark overlay
                overlay.tag = 99 // Tag it for removal later
                skillImageView.addSubview(overlay)

                // Add a cooldown label
                let cooldownLabel = UILabel(frame: skillImageView.bounds)
                cooldownLabel.text = "\(icons[i].cooldown)"
                cooldownLabel.textAlignment = .center
                cooldownLabel.textColor = .white
                cooldownLabel.font = UIFont.boldSystemFont(ofSize: 20)
                cooldownLabel.tag = 100 // Tag it for removal later
                skillImageView.addSubview(cooldownLabel)
            } else {
                // Remove any existing cooldown overlay if cooldown is 0
                skillImageView.viewWithTag(99)?.removeFromSuperview()
                skillImageView.viewWithTag(100)?.removeFromSuperview()
            }
        }
    }

    func updateHealthBar(_ id: UUID, _ currentHealth: Int, _ maxHealth: Int) {
        let healthPercentage = CGFloat(currentHealth) / CGFloat(maxHealth)
        let healthBar = gameStateIdToViews[id]?.healthBar
        let healthContainerWidth = gameStateIdToViews[id]?.healthContainer.bounds.width

        guard let healthBar = healthBar, let healthContainerWidth = healthContainerWidth else {
            return
        }

        UIView.animate(withDuration: 0.3) {
            healthBar.frame.size.width = healthContainerWidth * healthPercentage
        }

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

    // TODO: Implement restart
//    @IBAction func onRestart(_ sender: Any) {
//        print("restart")
//        self.gameEngine?.restart()
//    }
}

struct Views {
    var overallView: UIView
    var healthBar: UIView
    var healthContainer: UIView
}

struct SkillUiInfo {
    var iconImgString: String
    var cooldown: Int
}
