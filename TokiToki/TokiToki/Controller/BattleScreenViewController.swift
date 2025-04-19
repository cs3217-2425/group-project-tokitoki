//
//  BattleScreenViewController.swift
//  TokiToki
//
//  Created by proglab on 20/3/25.
//

import UIKit

class BattleScreenViewController: UIViewController, BattleLogObserver, BattleEffectsDelegate {
    internal var gameEngine: GameEngine?
    internal var levelManager: LevelManager?
    internal var skillImageViews: [UIImageView] = []
    internal var playerActionImageViews: [UIImageView] = []
    internal var playerTokisViews: [Views] = []
    internal var opponentTokisViews: [Views] = []
    internal var gameStateIdToViews: [UUID: Views] = [:]
    internal var opponentImageViews: [UIImageView] = []
    internal var playerTokisImageViews: [UIImageView] = []
    internal var opponentImageViewsToId: [UIImageView: UUID] = [:]
    internal var playerImageViewsToId: [UIImageView: UUID] = [:]

    @IBOutlet weak var toki1Name: UILabel!
    @IBOutlet weak var toki1LevelCircle: UIView!
    @IBOutlet var toki1HealthBarContainer: UIView!
    @IBOutlet var toki1HealthBar: UIView!
    @IBOutlet var toki1View: UIView!

    @IBOutlet weak var toki2Name: UILabel!
    @IBOutlet weak var toki2LevelCircle: UIView!
    @IBOutlet var toki2HealthBarContainer: UIView!
    @IBOutlet var toki2HealthBar: UIView!
    @IBOutlet var toki2View: UIView!

    @IBOutlet weak var toki3Name: UILabel!
    @IBOutlet weak var toki3LevelCircle: UIView!
    @IBOutlet var toki3HealthBar: UIView!
    @IBOutlet var toki3HealthBarContainer: UIView!
    @IBOutlet var toki3View: UIView!

    @IBOutlet weak var mainOppLevelCircle: UIView!
    @IBOutlet weak var mainOppName: UILabel!
    @IBOutlet var mainOppHealthBarContainer: UIView!
    @IBOutlet var mainOppHealthBar: UIView!
    @IBOutlet var mainOpponentView: UIView!

    @IBOutlet weak var opp2LevelCircle: UIView!
    @IBOutlet weak var opp2Name: UILabel!
    @IBOutlet var opponent2HealthBar: UIView!
    @IBOutlet var opponent2HealthBarContainer: UIView!
    @IBOutlet var opponent2View: UIView!

    @IBOutlet weak var opp3LevelCircle: UIView!
    @IBOutlet weak var opp3Name: UILabel!
    @IBOutlet var opponent3HealthBar: UIView!
    @IBOutlet var opponent3HealthBarContainer: UIView!
    @IBOutlet var opponent3View: UIView!

    @IBOutlet var noAction: UIImageView!
    @IBOutlet var consumables: UIImageView!
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

    internal var effectsManager: BattleEffectsManager?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        effectsManager?.cleanUp()
    }

    func getViewForEntity(id: UUID) -> UIView? {
        gameStateIdToViews[id]?.overallView
    }
}

struct Views {
    var overallView: UIView
    var healthBar: UIView
    var healthContainer: UIView
    var levelCircle: UIView
    var name: UILabel
}

struct SkillUiInfo {
    var iconImgString: String
    var cooldown: Int
}

extension BattleScreenViewController {
    @objc func testBattleEndOverlay() {
        let effect = BattleEndVisualFX(parentViewController: self)
        effect.play(isWin: true) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
