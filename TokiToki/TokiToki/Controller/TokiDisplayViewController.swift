//
//  TokiDisplayViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 20/3/25.
//

import UIKit

class TokiDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // UI Outlets
    @IBOutlet var tokiImageView: UIImageView?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var hpLabel: UILabel?
    @IBOutlet var expLabel: UILabel?
    @IBOutlet var levelLabel: UILabel?
    @IBOutlet var attackLabel: UILabel?
    @IBOutlet var defenseLabel: UILabel?
    @IBOutlet var healLabel: UILabel?
    @IBOutlet var speedLabel: UILabel?
    @IBOutlet var rarityLabel: UILabel?
    @IBOutlet var elementLabel: UILabel?
    @IBOutlet var equipmentTableView: UITableView?
    @IBOutlet var skillsTableView: UITableView?

    @IBOutlet var hpProgressView: UIProgressView?
    @IBOutlet var expProgressView: UIProgressView?
    @IBOutlet var attackProgressView: UIProgressView?
    @IBOutlet var defenseProgressView: UIProgressView?
    @IBOutlet var healProgressView: UIProgressView?
    @IBOutlet var speedProgressView: UIProgressView?

    @IBOutlet var levelUpButton: UIButton?

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
        
        let jsonPersistenceManager = JsonPersistenceManager()
        let player = PlayerManager.shared.getOrCreatePlayer()

        TokiDisplay.shared.loadEquipmentsFromJSON(using: jsonPersistenceManager, for: player)
        TokiDisplay.shared.updateUI(self)
        
        // Create and add a right swipe gesture recognizer
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            // Dismiss the view controller when a right swipe is detected
            // TODO: Save the current state of Toki
            dismiss(animated: true, completion: nil)
        }
    }

    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TokiDisplay.shared.tableView(tableView, numberOfRowsInSection: section, self)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        TokiDisplay.shared.tableView(tableView, cellForRowAt: indexPath, self)
    }

    @IBAction func changeEquipmentTapped(_ sender: UIButton) {
        TokiDisplay.shared.changeEquipmentTapped(sender, self)
    }

    @IBAction func changeSkillsTapped(_ sender: UIButton) {
        TokiDisplay.shared.changeSkillsTapped(sender, self)
    }

    /// level up button - when exp is full, enable the button and level up
    /// (pop up a UIAlertAction so the player can interact and add +1 to any stats of their liking)
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

extension TokiDisplayViewController {

    // Provide the trailing swipe configuration.
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
                   -> UISwipeActionsConfiguration? {

        TokiDisplay.shared.tableView(tableView,
                                                trailingSwipeActionsConfigurationForRowAt: indexPath,
                                                self)
    }
}

// MARK: - Crafting Popup
extension TokiDisplayViewController {

    func showCraftingPopup(for item: Equipment, at originalIndex: Int) {
        let craftVC = CraftingPopupViewController()

        // Pass along the original item and its index in the inventory
        craftVC.originalItem = item
        craftVC.originalItemIndex = originalIndex

        // Present as a popover or modal
        craftVC.modalPresentationStyle = .popover

        if let popover = craftVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }

        // Optionally, set a callback so we can reload Toki UI after crafting
        craftVC.onCraftComplete = { [weak self] in
            // Reload your table and other UI
            self?.equipmentTableView?.reloadData()
            TokiDisplay.shared.updateUI(self!)
        }

        present(craftVC, animated: true, completion: nil)
    }
}
