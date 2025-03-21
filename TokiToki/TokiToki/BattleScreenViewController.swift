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
    private var playerTokisViews: [UIView] = []
    private var opponentTokisViews: [UIView] = []
    private var gameStateIdToViews: [UUID: UIView] = [:]

    @IBOutlet weak var toki1HealthBarContainer: UIView!
    @IBOutlet weak var toki1HealthBar: UIView!
    @IBOutlet weak var toki1View: UIView!
    
    @IBOutlet weak var mainOppHealthBar: UIView!
    @IBOutlet weak var mainOpponentView: UIView!
    

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
    @IBOutlet weak var logBackground: UIView!
    
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
        return playerTokis.enumerated().map { index, toki in
            let entity = toki.createBattleEntity()
            gameStateIdToViews[entity.id] = playerTokisViews[index]
            return entity
        }
    }
    
    fileprivate func addMappingOfOpponentEntitiesToImageView(_ opponentEntities: [GameStateEntity]) {
        for (index, opponent) in opponentEntities.enumerated() {
            gameStateIdToViews[opponent.id] = opponentTokisViews[index]
        }
    }
    
    fileprivate func hideTokisIfNoTokiInThatSlot(_ entities: [GameStateEntity], _ views: [UIView]) {
        if views.count > entities.count {
            for i in entities.count..<views.count {
                views[i].isHidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        skill1.layer.borderWidth = 2
        skill1.layer.borderColor = UIColor.black.cgColor

        skillImageViews = [skill1, skill2, skill3]
        playerTokisViews = [toki1View, toki2, toki3]
        opponentTokisViews = [mainOpponentView, opponent2, opponent3]
        
//        logBackground.alpha = 0.5
//        battleLogDisplay.alpha = 1
        logBackground.layer.cornerRadius = 10
        logBackground.layer.borderColor = UIColor.white.cgColor
        logBackground.layer.borderWidth = 2

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
        let numberOfLinesToDisplay = 3
        let logToDisplay = log.count > numberOfLinesToDisplay ?
                            Array(log[(log.count - numberOfLinesToDisplay)...]) : log
        battleLogDisplay.text = logToDisplay.joined(separator: "\n")

//        guard let log = log else { return }
//        battleLogDisplay.text = log
    }
    
    fileprivate func animateMovement(_ tokiView: UIView, _ completion: @escaping () -> Void, _ isLeft: Bool) {
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
                if isLeft {
                    tokiView.frame.origin.x = rightPosition
                } else {
                    tokiView.frame.origin.x = leftPosition
                }
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
        
        animateMovement(tokiView, completion, isLeft)
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
    
    func updateHealthBar(currentHealth: CGFloat, maxHealth: CGFloat) {
        let healthPercentage = currentHealth / maxHealth
        
        // Animate the width change
        UIView.animate(withDuration: 0.3) {
            self.toki1HealthBar.frame.size.width = self.toki1HealthBarContainer.bounds.width * healthPercentage
        }
        
//        // Optionally change color based on health percentage
//        if healthPercentage > 0.5 {
//            self.toki1HealthBar.backgroundColor = .green
//        } else if healthPercentage > 0.25 {
//            self.healthBarView.backgroundColor = .yellow
//        } else {
//            self.healthBarView.backgroundColor = .red
//        }
    }
    
//    @IBAction func onRestart(_ sender: Any) {
//        print("restart")
//        self.gameEngine?.restart()
//    }
}
