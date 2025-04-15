//
//  TokiSelectionViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 6/4/25.
//

import UIKit

class TokiSelectionViewController: UIViewController {
    @IBOutlet var tokiTableView: UITableView?
    @IBOutlet var startButton: UIButton?
    
    // All available Tokis loaded from TokiDisplay.
    private let tokis = TokiDisplay.shared.allTokis
    // Array to hold the tokis selected for battle.
    var selectedTokis: [Toki] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tokiTableView?.dataSource = self
        tokiTableView?.delegate = self
    }
    
    // Called when the player taps the Start button
    @IBAction func startBattleTapped(_ sender: UIButton) {
        // Update the global player's toki list.
        for toki in selectedTokis {
            PlayerManager.shared.addToki(toki)
            print("[TokiSelection] Added Toki: \(toki.name) to PlayerManager")
        }
        
        // Switch to the BattleScreen storyboard.
        let battleStoryboard = UIStoryboard(name: "BattleScreen", bundle: nil)
        if let battleVC = battleStoryboard.instantiateInitialViewController() {
            battleVC.modalPresentationStyle = .fullScreen
            self.present(battleVC, animated: true, completion: nil)
        }
    }
    
    // Preserve this segue when the cell (excluding the switch area) is tapped.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTokiDisplay" {
            if let destVC = segue.destination as? TokiDisplayViewController {
                destVC.modalPresentationStyle = .fullScreen
            }
        }
    }
}

extension TokiSelectionViewController: UITableViewDataSource {
    // Returns the total number of Tokis.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokis.count
    }
    
    // Dequeues and configures each cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokiCell", for: indexPath) as? TokiTableSelectionCell else {
            return UITableViewCell()
        }
        
        let toki = tokis[indexPath.row]
        cell.nameLabel.text = toki.name
        
        // Set the switch state based on whether the toki is in selectedTokis.
        let isSelected = selectedTokis.contains { $0.id == toki.id }
        cell.selectionSwitch.setOn(isSelected, animated: false)
        
        // Configure the switch callback.
        cell.switchValueChanged = { [weak self] isOn in
            guard let self = self else { return }
            if isOn {
                if !self.selectedTokis.contains(where: { $0.id == toki.id }) {
                    self.selectedTokis.append(toki)
                }
            } else {
                if let index = self.selectedTokis.firstIndex(where: { $0.id == toki.id }) {
                    self.selectedTokis.remove(at: index)
                }
            }
        }
        
        return cell
    }
}

extension TokiSelectionViewController: UITableViewDelegate {
    // When the cell (outside of the switch) is tapped, display the Toki details.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedToki = tokis[indexPath.row]
        // Set the toki for display using TokiDisplay.
        TokiDisplay.shared.toki = selectedToki
        // Perform the segue to show the toki display.
        performSegue(withIdentifier: "ShowTokiDisplay", sender: self)
        // Deselect the cell for UI clarity.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
