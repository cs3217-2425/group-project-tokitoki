//
//  TokiDisplayViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 20/3/25.
//

import UIKit

class TokiDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // UI Outlets
    @IBOutlet weak var tokiImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var hpLabel: UILabel?
    @IBOutlet weak var expLabel: UILabel?
    @IBOutlet weak var levelLabel: UILabel?
    @IBOutlet weak var attackLabel: UILabel?
    @IBOutlet weak var defenseLabel: UILabel?
    @IBOutlet weak var healLabel: UILabel?
    @IBOutlet weak var speedLabel: UILabel?
    @IBOutlet weak var rarityLabel: UILabel?
    @IBOutlet weak var elementLabel: UILabel?
    @IBOutlet weak var equipmentTableView: UITableView?
    @IBOutlet weak var skillsTableView: UITableView?
    
    @IBOutlet weak var hpProgressView: UIProgressView?
    @IBOutlet weak var expProgressView: UIProgressView?
    @IBOutlet weak var attackProgressView: UIProgressView?
    @IBOutlet weak var defenseProgressView: UIProgressView?
    @IBOutlet weak var healProgressView: UIProgressView?
    @IBOutlet weak var speedProgressView: UIProgressView?
    
    @IBOutlet weak var levelUpButton: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign delegates
        equipmentTableView?.delegate = self
        equipmentTableView?.dataSource = self
        skillsTableView?.delegate = self
        skillsTableView?.dataSource = self
        
        hpProgressView?.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        expProgressView?.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        healProgressView?.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        attackProgressView?.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        defenseProgressView?.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        speedProgressView?.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        
        // Load Toki Data
        TokiDisplay.shared.loadTest()
        TokiDisplay.shared.updateUI(self)
    }

    
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TokiDisplay.shared.tableView(tableView, numberOfRowsInSection: section, self)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return TokiDisplay.shared.tableView(tableView, cellForRowAt: indexPath, self)
    }
    
    @IBAction func changeEquipmentTapped(_ sender: UIButton) {
        TokiDisplay.shared.changeEquipmentTapped(sender, self)
    }

    @IBAction func changeSkillsTapped(_ sender: UIButton) {
        TokiDisplay.shared.changeSkillsTapped(sender, self)
    }
    
    /// level up button - when exp is full, enable the button and level up (pop up a UIAlertAction so the player can interact and add +1 to any stats of their liking)
    @IBAction func levelUp(_ sender: UIButton) {
        TokiDisplay.shared.levelUp(sender, self)
    }
    
    @objc func handleEquipmentLongPress(_ gesture: UILongPressGestureRecognizer) {
        TokiDisplay.shared.handleEquipmentLongPress(gesture, self)
    }

    @objc func handleSkillLongPress(_ gesture: UILongPressGestureRecognizer) {
        TokiDisplay.shared.handleSkillLongPress(gesture, self)
    }
}
