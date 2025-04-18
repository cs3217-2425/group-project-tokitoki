//
//  BattleScreenViewController+setup.swift
//  TokiToki
//
//  Created by proglab on 15/4/25.
//

import UIKit

extension BattleScreenViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // One-time setup that should only happen once
        
        resetBattleState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset the battle state when returning to this screen
        resetBattleState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Re-enable the interactive pop gesture when leaving this screen
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func resetBattleState() {
        // Put all the initialization code here
        configureSkillIcons()
        configureViews()
        configureLogBackground()
        addGestureRecognisers()
        effectsManager = BattleEffectsManager(viewController: self)
        var tokis = PlayerManager.shared.getTokisForBattle()
        if tokis.isEmpty {
            tokis = PlayerManager.shared.getFirstThreeOwnedTokis()
        }
        configure(tokis, [dragonMonsterToki, rhinoMonsterToki, golemMonsterToki])
    }
    
    func configure(_ playerTokis: [Toki], _ enemyTokis: [Toki]) {
        setupNameAndLevelCircle(enemyTokis, opponentTokisViews, false)
        setupNameAndLevelCircle(playerTokis, playerTokisViews, true)
        let opponentEntities = enemyTokis.map { createMonsterEntity($0) }
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

    internal func createPlayerEntitiesAndAddMappingToView(_ playerTokis: [Toki]) -> [GameStateEntity] {
        playerTokis.enumerated().map { index, toki in
            let entity = toki.createBattleEntity()
            gameStateIdToViews[entity.id] = playerTokisViews[index]
            playerTokisImageViews[index].image = UIImage(named: tokiToIconImage[toki.name] ??
                                                         "peg-red@1x")
            return entity
        }
    }
    
    internal func setupNameAndLevelCircle(_ tokis: [Toki], _ views: [Views],
                                          _ isPlayerTokis: Bool) {
        tokis.enumerated().map { index, toki in
            let levelCircle = views[index].levelCircle
            levelCircle.layer.cornerRadius = levelCircle.frame.width / 2
            levelCircle.backgroundColor = elementToColour[toki.elementType[0]]
            
            let levelLabel = UILabel()
            levelLabel.translatesAutoresizingMaskIntoConstraints = false
            levelLabel.text = "\(toki.level)"
            levelLabel.textAlignment = .center
            levelLabel.font = UIFont.boldSystemFont(ofSize: levelCircle.frame.width / 2)
            levelLabel.textColor = toki.elementType[0] == .light ? .black : .white
            levelCircle.addSubview(levelLabel)
            
            NSLayoutConstraint.activate([
                levelLabel.centerXAnchor.constraint(equalTo: levelCircle.centerXAnchor),
                levelLabel.centerYAnchor.constraint(equalTo: levelCircle.centerYAnchor)
            ])
            
            let name = views[index].name
            name.text = toki.name
            name.textColor = elementToColour[toki.elementType[0]]
            name.shadowColor = UIColor.black
            name.shadowOffset = CGSize(width: 1, height: 1)
            name.sizeToFit()
            
            let currentY = name.frame.origin.y
            name.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                name.centerXAnchor.constraint(equalTo: views[index].overallView.centerXAnchor),
                name.topAnchor.constraint(equalTo: views[index].overallView.topAnchor, constant: currentY)
            ])
            
            if index == 0 && !isPlayerTokis {
                name.font = UIFont.boldSystemFont(ofSize: 24)
                let verticalAdjustment: CGFloat = 8
                name.center.y -= verticalAdjustment
            } else {
                name.font = UIFont.boldSystemFont(ofSize: 18)
            }
        }
    }

    internal func addMappingOfOpponentEntitiesToImageView(_ opponentEntities: [GameStateEntity]) {
        for (index, opponent) in opponentEntities.enumerated() {
            gameStateIdToViews[opponent.id] = opponentTokisViews[index]
            opponentImageViewsToId[opponentImageViews[index]] = opponent.id
            opponentImageViews[index].image = UIImage(named: tokiToIconImage[opponent.name] ??
                                                         "peg-red@1x")
        }
    }

    internal func addMappingOfPlayerEntitiesToImageView(_ playerEntities: [GameStateEntity]) {
        for (index, player) in playerEntities.enumerated() {
            gameStateIdToViews[player.id] = playerTokisViews[index]
            playerImageViewsToId[playerTokisImageViews[index]] = player.id
        }
    }

    internal func hideTokisIfNoTokiInThatSlot(_ entities: [GameStateEntity], _ views: [Views]) {
        if views.count > entities.count {
            for i in entities.count..<views.count {
                views[i].overallView.isHidden = true
            }
        }
    }
    
    internal func configureSkillIcons() {
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
        playerTokisViews = [Views(overallView: toki1View, healthBar: toki1HealthBar,
                                  healthContainer: toki1HealthBarContainer, levelCircle: toki1LevelCircle,
                                  name: toki1Name),
                            Views(overallView: toki2View, healthBar: toki2HealthBar,
                                  healthContainer: toki2HealthBarContainer, levelCircle: toki2LevelCircle,
                                  name: toki2Name),
                            Views(overallView: toki3View, healthBar: toki3HealthBar,
                                  healthContainer: toki3HealthBarContainer, levelCircle: toki3LevelCircle,
                                  name: toki3Name)]
        opponentTokisViews = [Views(overallView: mainOpponentView, healthBar: mainOppHealthBar,
                                    healthContainer: mainOppHealthBarContainer, levelCircle: mainOppLevelCircle,
                                    name: mainOppName),
                              Views(overallView: opponent2View, healthBar: opponent2HealthBar,
                                    healthContainer: opponent2HealthBarContainer, levelCircle: opp2LevelCircle,
                                    name: opp2Name),
                              Views(overallView: opponent3View, healthBar: opponent3HealthBar,
                                    healthContainer: opponent3HealthBarContainer, levelCircle: opp3LevelCircle,
                                    name: opp3Name)]

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

        consumables.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(useConsumables(_:)))
        consumables.addGestureRecognizer(tapGesture)

        noAction.isUserInteractionEnabled = true
        let noActionTapGesture = UITapGestureRecognizer(target: self, action: #selector(takeNoAction(_:)))
        noAction.addGestureRecognizer(noActionTapGesture)

        playerActionImageViews = skillImageViews + [consumables, noAction]
    }
}

let elementToColour: [ElementType: UIColor] = [
    .fire: .systemRed,
    .water: .systemBlue,
    .ice: .systemCyan,
    .lightning: .systemYellow,
    .earth: .systemBrown,
    .air: .systemGray,
    .light: UIColor(red: 255/255, green: 259/255, blue: 253/255, alpha: 1.0),
    .dark: .systemPurple,
    .neutral: .systemPink
]


