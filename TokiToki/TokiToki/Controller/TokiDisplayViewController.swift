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
    
    var toki: Toki
    
    required init?(coder aDecoder: NSCoder) {
        // Initialize toki with a default instance.
        // Replace the following with an appropriate default if needed.
        self.toki = Toki(name: "Default Toki",
                         rarity: .common,
                         baseStats: TokiBaseStats(hp: 100, attack: 50, defense: 50, speed: 50, heal: 100, exp: 42),
                         skills: [],
                         equipments: [],
                         elementType: .fire,
                         level: 1)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign delegates
        equipmentTableView?.delegate = self
        equipmentTableView?.dataSource = self
        skillsTableView?.delegate = self
        skillsTableView?.dataSource = self
        
        // Load Toki Data
        toki = loadTest()
        updateUI()
    }

    func loadTest() -> Toki {
        let elementsSystem = ElementsSystem()
        
        let effectCalculatorFactory = EffectCalculatorFactory(elementsSystem: elementsSystem)
        
        let skillsFactory = SkillFactory(effectCalculatorFactory: effectCalculatorFactory)
        
        let skill = skillsFactory.createAttackSkill(
            name: "Thunder Strike",
            description: "Strikes with thunder power",
            elementType: .light,
            basePower: 50,
            cooldown: 3,
            targetType: .single,
            statusEffect: .paralysis,
            statusEffectChance: 0.3,
            statusEffectDuration: 2
        )
        
        let equipmentFactory = EquipmentFactory()
        
        let equipment = equipmentFactory.createEquipment(
            name: "Magic Staff",
            description: "A magical staff",
            elementType: .fire,
            buff: Buff(attack: 10, defense: 10, speed: 10)
        )
        
        var toki = Toki(name: "Tokimon Omicron 1",
                        rarity: .common,
                        baseStats:
                            TokiBaseStats(
                                hp: 100,
                                attack: 50,
                                defense: 50,
                                speed: 50,
                                heal: 100,
                                exp: 492),
                        skills: [skill],
                        equipments: [equipment],
                        elementType: .fire,
                        level: 1)
        
        return toki
    }
    
    func updateUI() {
        tokiImageView?.image = UIImage(named: toki.name)
        nameLabel?.text = toki.name
        levelLabel?.text = "Level: \(toki.level)"
        hpProgressView?.progress = Float(toki.baseStats.hp / 420)
        attackLabel?.text = "Attack: \(toki.baseStats.attack)"
        defenseLabel?.text = "Defense: \(toki.baseStats.defense)"
        speedLabel?.text = "Speed: \(toki.baseStats.speed)"

        hpLabel?.text = "HP: \(toki.baseStats.hp)"
        expLabel?.text = "Experience: \(toki.baseStats.exp)"
        attackLabel?.text = "Attack: \(toki.baseStats.attack)"
        defenseLabel?.text = "Defense: \(toki.baseStats.defense)"
        healLabel?.text = "Heal: \(toki.baseStats.heal)"
        speedLabel?.text = "Speed: \(toki.baseStats.speed)"
        rarityLabel?.text = "Rarity: \(toki.rarity)"
        elementLabel?.text = "Element: \(toki.elementType)"
        
        // Progress views: rawValue / maxValue (0.0 to 1.0)
        hpProgressView?.progress = Float(toki.baseStats.hp) / 420.0
        expProgressView?.progress = Float(toki.baseStats.exp) / 100.0
        
        if expProgressView?.progress == 1.0 {
            levelUpButton?.isEnabled = true
        } else {
            levelUpButton?.isEnabled = false
        }
        
        // If Attack/Defense/Heal/Speed are out of 100, just divide by 100:
        attackProgressView?.progress = Float(toki.baseStats.attack) / 100.0
        defenseProgressView?.progress = Float(toki.baseStats.defense) / 100.0
        healProgressView?.progress = Float(toki.baseStats.heal) / 100.0
        speedProgressView?.progress = Float(toki.baseStats.speed) / 100.0
        
        hpProgressView?.progressTintColor = .systemRed
        
        equipmentTableView?.reloadData()
        skillsTableView?.reloadData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokiTableCell", for: indexPath) as? TokiTableCell else {
            return UITableViewCell()
        }
        
        if tableView == equipmentTableView {
            let equipmentName = toki.equipment[indexPath.row].name
            cell.nameLabel.text = equipmentName
            cell.itemImageView.image = UIImage(named: equipmentName) // if your asset name matches equipmentName
        } else { // for skillsTableView
            let skillName = toki.skills[indexPath.row].name
            cell.nameLabel.text = skillName
            cell.itemImageView.image = UIImage(named: skillName) // if you have an image for the skill
        }
        
        return cell
    }
    
    // Example Action to Change Equipment
    @IBAction func changeEquipmentTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Change Equipment", message: "Select a new equipment", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Magic Staff", style: .default, handler: { _ in
//            self.toki.equipment[0] = "Magic Staff"
            self.updateUI()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Example Action to Change Skills
    @IBAction func changeSkillsTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Change Skills", message: "Select a new skill", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thunder Strike", style: .default, handler: { _ in
//            self.toki.skills[0] = "Thunder Strike"
            self.updateUI()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// level up button - when exp is full, enable the button and level up (pop up a UIAlertAction so the player can interact and add +1 to any stats of their liking)
    @IBAction func levelUp(_ sender: UIButton) {
        if toki.baseStats.exp >= 100 {
            let alert = UIAlertController(title: "Level Up", message: "Choose a stat to increase", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Attack", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: 10, attack: 1, defense: 0, speed: 0, heal: 0, exp: 0))
                self.updateUI()
            }))
            alert.addAction(UIAlertAction(title: "Defense", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: 10, attack: 0, defense: 1, speed: 0, heal: 0, exp: 0))
                self.updateUI()
            }))
            alert.addAction(UIAlertAction(title: "Speed", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: 10, attack: 0, defense: 0, speed: 1, heal: 0, exp: 0))
                self.updateUI()
            }))
            alert.addAction(UIAlertAction(title: "Heal", style: .default, handler: { _ in
                self.toki.levelUp(stat: TokiBaseStats(hp: 10, attack: 0, defense: 0, speed: 0, heal: 1, exp: 0))
                self.updateUI()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            
            present(alert, animated: true, completion: nil)
        }
    }
}


// TODO: Link to CoreData

// TODO: Enable the buttons to change the equipment and skills
