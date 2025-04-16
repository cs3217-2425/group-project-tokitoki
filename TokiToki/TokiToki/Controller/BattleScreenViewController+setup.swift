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

    private func resetBattleState() {
        // Put all your initialization code here
        configureSkillIcons()
        configureViews()
        configureLogBackground()
        addGestureRecognisers()
        effectsManager = BattleEffectsManager(viewController: self)
        var tokis = PlayerManager.shared.getTokisForBattle()
        if tokis.isEmpty {
            tokis = [knightToki, wizardToki, archerToki]
        }
        configure(tokis, [monsterToki, monsterToki, monsterToki])
    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureSkillIcons()
//        configureViews()
//        configureLogBackground()
//        addGestureRecognisers()
//        effectsManager = BattleEffectsManager(viewController: self)
//        var tokis = PlayerManager.shared.getTokisForBattle()
//        if tokis.isEmpty {
//            tokis = [knightToki, wizardToki, archerToki]
//        }
//        configure(tokis, [basicMonster, basicMonster2, basicMonster3])
//    }
    
    func configure(_ playerTokis: [Toki], _ enemyTokis: [Toki]) {
        let opponentEntities = enemyTokis.map { createMonsterEntity($0) }
        let playerEntities = createPlayerEntitiesAndAddMappingToView(playerTokis)
        hideTokisIfNoTokiInThatSlot(playerEntities, playerTokisViews)
        hideTokisIfNoTokiInThatSlot(opponentEntities, opponentTokisViews)
        addMappingOfOpponentEntitiesToImageView(opponentEntities)
        addMappingOfPlayerEntitiesToImageView(playerEntities)

        self.gameEngine = GameEngine(playerTeam: playerEntities, opponentTeam: opponentEntities)
//        self.gameEngine?.restart()
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

    internal func addMappingOfOpponentEntitiesToImageView(_ opponentEntities: [GameStateEntity]) {
        for (index, opponent) in opponentEntities.enumerated() {
            gameStateIdToViews[opponent.id] = opponentTokisViews[index]
            opponentImageViewsToId[opponentImageViews[index]] = opponent.id
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
                                  healthContainer: toki1HealthBarContainer),
                            Views(overallView: toki2View, healthBar: toki2HealthBar,
                                  healthContainer: toki2HealthBarContainer),
                            Views(overallView: toki3View, healthBar: toki3HealthBar,
                                  healthContainer: toki3HealthBarContainer)]
        opponentTokisViews = [Views(overallView: mainOpponentView, healthBar: mainOppHealthBar,
                                    healthContainer: mainOppHealthBarContainer),
                              Views(overallView: opponent2View, healthBar: opponent2HealthBar,
                                    healthContainer: opponent2HealthBarContainer),
                              Views(overallView: opponent3View, healthBar: opponent3HealthBar,
                                    healthContainer: opponent3HealthBarContainer)]

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
