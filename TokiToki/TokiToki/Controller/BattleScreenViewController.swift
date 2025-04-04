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
    private var playerTokisImageViews: [UIImageView] = []
    private var opponentImageViewsToId: [UIImageView: UUID] = [:]
    private var playerImageViewsToId: [UIImageView: UUID] = [:]

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

    private var effectsManager: BattleEffectsManager?

    func configure(_ playerTokis: [Toki], _ opponentEntities: [GameStateEntity]) {
        let playerEntities = createPlayerEntitiesAndAddMappingToView(playerTokis)
        hideTokisIfNoTokiInThatSlot(playerEntities, playerTokisViews)
        hideTokisIfNoTokiInThatSlot(opponentEntities, opponentTokisViews)
        addMappingOfOpponentEntitiesToImageView(opponentEntities)
        addMappingOfPlayerEntitiesToImageView(playerEntities)

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
    
    fileprivate func addMappingOfPlayerEntitiesToImageView(_ playerEntities: [GameStateEntity]) {
        for (index, player) in playerEntities.enumerated() {
            gameStateIdToViews[player.id] = playerTokisViews[index]
            playerImageViewsToId[playerTokisImageViews[index]] = player.id
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

        effectsManager = BattleEffectsManager(viewController: self)

        configure([knightToki, wizardToki, archerToki], [basicMonster, basicMonster2, basicMonster3])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        effectsManager?.cleanUp()
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
        playerTokisImageViews = [toki1, toki2, toki3]
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
        
        for imageView in playerTokisImageViews {
            imageView.isUserInteractionEnabled = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerTokiTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
        }
    }

    @objc func skillTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        skillImageViews.forEach { $0.isHidden = true }
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

    func update(log: [String]) {
        let numberOfLinesToDisplay = 3
        let logToDisplay = log.count > numberOfLinesToDisplay ?
                            Array(log[(log.count - numberOfLinesToDisplay)...]) : log
        battleLogDisplay.text = logToDisplay.joined(separator: "\n")
    }

    fileprivate func moveTokiView(_ tokiView: UIView, _ isAlly: Bool, _ leftPosition: CGFloat,
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
    
    fileprivate func animateMovement(_ tokiView: UIView, _ completion: @escaping () -> Void, _ isAlly: Bool) {
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

    fileprivate func removeCooldownOverlay(_ skillImageView: UIImageView) {
        skillImageView.subviews.forEach { $0.removeFromSuperview() }
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

    func getViewForEntity(id: UUID) -> UIView? {
        gameStateIdToViews[id]?.overallView
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
