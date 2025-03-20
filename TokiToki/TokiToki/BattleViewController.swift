//
//  ViewController.swift
//  TokiToki
//
//  Created by proglab on 14/3/25.
//

import UIKit

//class BattleViewController: UIViewController, BattleLogObserver {
//    private var gameEngine: GameEngine?
////    private var playerTokis: [Toki]
////    private var opponents: [Toki]
//
//    @IBOutlet var skill3: UIImageView!
//    @IBOutlet var skill2: UIImageView!
//    @IBOutlet var skill1: UIImageView!
//    @IBOutlet var toki1: UIImageView!
//    @IBOutlet var toki2: UIImageView!
//    @IBOutlet var toki3: UIImageView!
//    @IBOutlet var battleLogDisplay: UILabel!
//
//    var skillImageViews: [UIImageView] = []
//   // var skillActions: [() -> Void] = []
//
//    func configure(_ playerTokis: [Toki], _ opponents: [Toki]) {
//        let playerEntities = playerTokis.reduce(into: [UUID: GameStateEntity]()) { result, toki in
//            let entity = toki.createBattleEntity()
//            result[entity.id] = entity
//        }
//        let opponentEntities = opponents.reduce(into: [UUID: GameStateEntity]()) { result, opponent in
//            let entity = opponent.createBattleEntity()
//            entity.addComponent(AIComponent(entityId: entity.id, rules: [], skills: opponent.skills))
//            result[entity.id] = entity
//        }
//
//        self.gameEngine = GameEngine(playerTeam: playerEntities, opponentTeam: opponentEntities)
//        self.gameEngine?.addObserver(self)
//        self.gameEngine?.startBattle()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        skillImageViews = [skill1, skill2, skill3]
////        skillActions = [
////            { print("Skill 1 tapped!") }, // Action for skill1
////            { print("Skill 2 tapped!") }, // Action for skill2
////            { print("Skill 3 tapped!") }  // Action for skill3
////        ]
//
//        for (index, skillImageView) in skillImageViews.enumerated() {
//            skillImageView.isUserInteractionEnabled = true
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(skillTapped(_:)))
//            skillImageView.addGestureRecognizer(tapGesture)
//            skillImageView.tag = index
//        }
//
//        configure([wizardToki], [wizardToki])
//    }
//
//    @objc func skillTapped(_ sender: UITapGestureRecognizer) {
//        guard let tappedImageView = sender.view as? UIImageView else { return }
//        gameEngine?.useTokiSkill(tappedImageView.tag)
//    }
//
//    func update(log: [String]) {
//        let combinedLog = log.joined(separator: "\n")
//        battleLogDisplay.text = combinedLog
//    }
//}
