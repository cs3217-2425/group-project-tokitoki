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
    private var playerTokisImageViews: [UIImageView] = []
    private var opponentsImageViews: [UIImageView] = []
    private var gameStateIdToImageView: [UUID: UIImageView] = [:]

    @IBOutlet var skill1: UIImageView!
    @IBOutlet var skill2: UIImageView!
    @IBOutlet var skill3: UIImageView!
    @IBOutlet weak var opponent1: UIImageView!
    @IBOutlet weak var opponent2: UIImageView!
    @IBOutlet weak var opponent3: UIImageView!
    @IBOutlet weak var toki1: UIImageView!
    @IBOutlet weak var toki2: UIImageView!
    @IBOutlet weak var toki3: UIImageView!
    @IBOutlet var battleLogDisplay: UILabel!
    
    
    
    func configure(_ playerTokis: [Toki], _ opponentEntities: [GameStateEntity]) {
        let playerEntities = createPlayerEntitiesAndAddMappingToView(playerTokis)
        hideTokisIfNoTokiInThatSlot(playerEntities, playerTokisImageViews)
        hideTokisIfNoTokiInThatSlot(opponentEntities, opponentsImageViews)
        addMappingOfOpponentEntitiesToImageView(opponentEntities)

        self.gameEngine = GameEngine(playerTeam: playerEntities, opponentTeam: opponentEntities)
        self.gameEngine?.addObserver(self)
        self.gameEngine?.addDelegate(self)
        self.gameEngine?.startBattle()
    }
    
    fileprivate func createPlayerEntitiesAndAddMappingToView(_ playerTokis: [Toki]) -> [GameStateEntity] {
        return playerTokis.enumerated().map { index, toki in
            let entity = toki.createBattleEntity()
            gameStateIdToImageView[entity.id] = playerTokisImageViews[index]
            return entity
        }
    }
    
    fileprivate func addMappingOfOpponentEntitiesToImageView(_ opponentEntities: [GameStateEntity]) {
        for (index, opponent) in opponentEntities.enumerated() {
            gameStateIdToImageView[opponent.id] = opponentsImageViews[index]
        }
    }
    
    fileprivate func hideTokisIfNoTokiInThatSlot(_ entities: [GameStateEntity], _ imageViews: [UIImageView]) {
        if imageViews.count > entities.count {
            for i in entities.count..<imageViews.count {
                imageViews[i].isHidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        skill1.layer.borderWidth = 2
        skill1.layer.borderColor = UIColor.black.cgColor

        skillImageViews = [skill1, skill2, skill3]
        playerTokisImageViews = [toki1, toki2, toki3]
        opponentsImageViews = [opponent1, opponent2, opponent3]

        for (index, skillImageView) in skillImageViews.enumerated() {
            skillImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(skillTapped(_:)))
            skillImageView.addGestureRecognizer(tapGesture)
            skillImageView.tag = index
        }
        
        configure([wizardToki], [basicMonster])
    }

    @objc func skillTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        skillImageViews.forEach { $0.isHidden = true }
        gameEngine?.useTokiSkill(tappedImageView.tag)
    }

    func update(log: [String]) {
        let numberOfLinesToDisplay = 5
        let logToDisplay = log
        if log.count > numberOfLinesToDisplay {
            let startIndex = log.count - numberOfLinesToDisplay
            let logToDisplay = Array(log[startIndex...])
        }
        let combinedLog = logToDisplay.joined(separator: "\n")
        battleLogDisplay.text = combinedLog
    }
    
    func showUseSkill(_ id: UUID, completion: @escaping () -> Void = {}) {
        let tokiView = gameStateIdToImageView[id]
        guard let tokiView = tokiView else {
            completion() 
            return
        }
        
        UIView.animate(withDuration: 1.0, animations: {
            tokiView.frame.origin.x += 50
        }) { _ in
            UIView.animate(withDuration: 1.0, animations: {
                tokiView.frame.origin.x -= 50
            }, completion: { _ in
                completion()
            })
        }
    }
    
    func updateSkillIcons(_ icons: [String]?) {
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
            skillImageViews[i].image = UIImage(named: icons[i])
        }
    }
}
