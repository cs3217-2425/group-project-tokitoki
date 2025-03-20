//
//  TokiDisplayViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 20/3/25.
//

import UIKit

class TokiDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // UI Outlets
    @IBOutlet weak var tokiImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var hpProgressView: UIProgressView!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var defenseLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var equipmentTableView: UITableView!
    @IBOutlet weak var skillsTableView: UITableView!
    
    // Data Models
    struct Toki {
        var name: String
        var level: Int
        var hp: Float
        var maxHp: Float
        var attack: Int
        var defense: Int
        var speed: Int
        var equipment: [String]
        var skills: [String]
        var image: UIImage?
    }
    
    var toki = Toki(name: "Toki Warrior", level: 5, hp: 80, maxHp: 100, attack: 50, defense: 40, speed: 30,
                    equipment: ["Iron Sword", "Steel Shield"],
                    skills: ["Fire Slash", "Ice Blast"],
                    image: UIImage(named: "toki_image"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign delegates
        equipmentTableView.delegate = self
        equipmentTableView.dataSource = self
        skillsTableView.delegate = self
        skillsTableView.dataSource = self
        equipmentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        skillsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Load Toki Data
        updateUI()
    }
    
    func updateUI() {
        tokiImageView.image = toki.image
        nameLabel.text = toki.name
        levelLabel.text = "Level: \(toki.level)"
        hpProgressView.progress = toki.hp / toki.maxHp
        attackLabel.text = "Attack: \(toki.attack)"
        defenseLabel.text = "Defense: \(toki.defense)"
        speedLabel.text = "Speed: \(toki.speed)"
        
        equipmentTableView.reloadData()
        skillsTableView.reloadData()
    }
    
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == equipmentTableView {
            return toki.equipment.count
        } else {
            return toki.skills.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if tableView == equipmentTableView {
            cell.textLabel?.text = toki.equipment[indexPath.row]
        } else {
            cell.textLabel?.text = toki.skills[indexPath.row]
        }
        
        return cell
    }
    
    // Example Action to Change Equipment
    @IBAction func changeEquipmentTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Change Equipment", message: "Select a new equipment", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Magic Staff", style: .default, handler: { _ in
            self.toki.equipment[0] = "Magic Staff"
            self.updateUI()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Example Action to Change Skills
    @IBAction func changeSkillsTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Change Skills", message: "Select a new skill", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thunder Strike", style: .default, handler: { _ in
            self.toki.skills[0] = "Thunder Strike"
            self.updateUI()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
